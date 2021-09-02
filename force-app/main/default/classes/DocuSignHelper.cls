/*********************************************************************************************
    Description: This class is used to create the Authentication Header, create Recipients, Contact DocuSign Recipient View and new DocuSign Document instance
    History:
    15/05/2017   Diane Enriquez/Appirio    Initial Development
 **********************************************************************************************/
public class DocuSignHelper{
    
    /**
    * Constructor
    */
    private DocuSign_Credential__c credential;
        public DocuSignHelper(){
        credential = DocuSign_Credential__c.getOrgDefaults();
    }   
    
    /**
    * This method is used to create recipient instance
    * Params:
    * @name: Name of Recipient
    * @email: Email of Recipient
    * @title: Title of Recipient
    * @recipientId: Id of Recipient
    * @roleName: roleName of Recipient
    * @routingOrder: routingOrder of Recipient
    */ 
    public DocuSignRESTAPI.DocuSignUser getRecipient(String name, String email, String title, String recipientId, String roleName, String routingOrder){
        DocuSignRESTAPI.DocuSignUser recipient = new DocuSignRESTAPI.DocuSignUser();
        recipient.email = email;
        recipient.name = name;
        recipient.roleName = roleName;
        recipient.RoutingOrder = routingOrder;
        recipient.recipientId = recipientId;
        recipient.tabs.textTabs.add(new DocuSignRESTAPI.Tab('Title', title, recipientId));
        return recipient;
    } 
    
    /**
    * This method is used to create CarbonCopy list 
    * Params:
    * @accMembers: List of account team member for which carbon copy to be created
    */  
    public List<DocuSignRESTAPI.DocuSignUser> getCarbonCopyList(List<AccountTeamMember> accMembers){
        List<DocuSignRESTAPI.DocuSignUser> carbonCopies = new List<DocuSignRESTAPI.DocuSignUser>();
        Integer recipientId = 100;
        for(AccountTeamMember member: accMembers){
            DocuSignRESTAPI.DocuSignUser recipient = new DocuSignRESTAPI.DocuSignUser();
            recipient.email = member.User.Email;
            recipient.name = member.User.Name;
            recipient.roleName = 'CarbonCopy';
            recipient.routingOrder = '3';
            recipient.recipientId = String.valueof(recipientId++);
            carbonCopies.add(recipient);
        }
        return carbonCopies;
    } 
    
    /**
    * This method is used to create auth header
    * Params:
    * @return: auth string
    */  
    public String createDocuSignAuthHeader(){
        return '{"Username": "'+credential.username__C+'","Password": "'+credential.password__c+'","IntegratorKey": "' + credential.Integrator_Key__C + '"}';
    }
    
    /**
    * This method is used to create DocuSign document instance
    * Params:
    * @attachment: Attachment which is to be added in DocuSign document
    * @docId: Unique document id
    */ 
    public DocuSignRESTAPI.Document createDocumentInstance (Attachment attachment, String docId){
        DocuSignRESTAPI.Document document = new DocuSignRESTAPI.Document();
        document.name = attachment.Name;
        document.documentId = docId;
        document.includeInDownload = true;
        document.display = 'modal';
        document.signerMustAcknowledge = 'no_interaction';
        document.documentBase64 = EncodingUtil.base64encode(attachment.Body);
        if(attachment.name.contains('.')){
            document.fileExtension = attachment.name.substring(attachment.name.indexof('.')+1, attachment.name.length());
        }
        return document;          
    }
    
    /**
    * This method is used to create DocuSign recipient view for the passed contact
    * Params:
    * @envId: Envelope Id
    * @contact: Contact for which view to be created
    */ 
    public string getDocuSignRecipientView(String envId,  Contact contact){
        List<Application_Log__c> logs = new List<Application_Log__c>();
        try{
           
            DocuSignRESTAPI DocuSignAPI = new DocuSignRESTAPI();
            DocuSignAPI.addHeader('X-DocuSign-Authentication', createDocuSignAuthHeader());
            DocuSignAPI.addHeader('Content-Type', 'application/json');
            
            boolean envelopeSent = false;
            boolean changeRecipient = false;
            // Get Signer 1 details
            List<dsfs__DocuSign_Recipient_Status__c> statusList = [select name, Title_Tab_Id__c, dsfs__Recipient_Status__c, 
                                                                    dsfs__Parent_Status_Record__r.dsfs__Envelope_status__c, 
                                                                    dsfs__DocuSign_Recipient_Email__c, 
                                                                    dsfs__DocuSign_Recipient_Title__c,
                                                                    Custom_Field_Id__c  
                                                                from dsfs__DocuSign_Recipient_Status__c 
                                                                where dsfs__Envelope_Id__c =: envId
                                                                and dsfs__DocuSign_Routing_Order__c = 1];
                    
            if(!statusList.isEmpty()){
                DocuSignRESTAPI.CustomFields2 resultFields;
                if(statusList[0].dsfs__Parent_Status_Record__r.dsfs__Envelope_status__c == 'sent'){
                    envelopeSent = true;
                }
                if(statusList[0].dsfs__Recipient_Status__c != 'completed'){
                    changeRecipient = true;
                }
                if(changeRecipient){
                    
                    DocuSignRESTAPI.ErrorDetails errorDetails;
                    
                    // Update Signer 1 details
                    DocuSignRESTAPI.Recipient recipient = new DocuSignRESTAPI.Recipient();
                    recipient.signers.add(getRecipient(contact.Name, contact.Email, contact.title, '1', 'Signer 1', '1'));
            
                    DocuSignRESTAPI.RecipientUpdateSummary summary = DocuSignAPI.updateRecipient(credential.Account_Id__c, envId, recipient);
                    boolean isRecipientUpdated = false;
                    
                    if(summary.recipientUpdateResults != null && !summary.recipientUpdateResults.isEmpty()){
                        errorDetails = summary.recipientUpdateResults[0].errorDetails;
                        
                        if(errorDetails.errorCode == 'Success'){
                            
                            // Update title of recipient 1
                            DocuSignRestAPI.Tabs tabs = new DocuSignRESTAPI.TAbs();
                            DocuSignRestAPI.Tab title = new DocuSignRestAPI.Tab('ContactTitle',contact.title, '1');
                            title.tabId = statusList[0].Title_Tab_Id__c;
                            //tabs.titleTabs.add(title);
                            tabs.textTabs.add(title);
                            DocuSignRESTAPI.EnvelopeResult tabUpdateResult = DocuSignAPI.updateTab(credential.Account_Id__c, envId, '1', tabs);
                            if(tabUpdateResult.errorCode != 'Success'){
                                logs.add(new Application_Log__c(Application__c = 'DocuSignAPI.updateTab', Description__c = 'Contact: '+contact.Id+'\nFailed to Update Title Tab', Error_Message__c = 'Failed to update tab. '+tabUpdateResult.errorCode+'-'+tabUpdateResult.message, Type__c= 'Error'));
                            }
                            
                            
                            if(statusList[0].Custom_Field_Id__c == '' || statusList[0].Custom_Field_Id__c == null){
                                // Add Contact as merge field which allows title to be updated on Salesforce
                                DocuSignRESTAPI.CustomFields fields = new DocuSignRESTAPI.CustomFields();
                                fields.textCustomFields.add(new DocuSignRESTAPI.TextCustomField('salesforce', '', 'Contact', 'true', 'true', contact.Id+'~'+contact.Name));
                                
                                resultFields = DocuSignAPI.createCustomFields(credential.Account_Id__c, envId, fields);
                            }
                            else{
                                // Add Contact as merge field which allows title to be updated on Salesforce
                                DocuSignRESTAPI.CustomFields2 fields = new DocuSignRESTAPI.CustomFields2();
                                fields.textCustomFields.add(new DocuSignRESTAPI.TextCustomField2('salesforce', statusList[0].Custom_Field_Id__c, 'Contact', 'true', 'true', contact.Id+'~'+contact.Name));
                            
                                resultFields = DocuSignAPI.deleteCustomFields(credential.Account_Id__c, envId, fields);
                                
                                // Add Contact as merge field which allows title to be updated on Salesforce
                                DocuSignRESTAPI.CustomFields fields2 = new DocuSignRESTAPI.CustomFields();
                                fields2.textCustomFields.add(new DocuSignRESTAPI.TextCustomField('salesforce', '', 'Contact', 'true', 'true', contact.Id+'~'+contact.Name));
                                
                                resultFields = DocuSignAPI.createCustomFields(credential.Account_Id__c, envId, fields2);
                            }
                            if(resultFields.textCustomFields != null && resultFields.textCustomFields.size() > 0 &&
                                resultFields.textCustomFields[0].errorDetails != null && resultFields.textCustomFields[0].errorDetails.errorCode != 'Success'){
                                DocuSignRESTAPI.ErrorDetails errorDetail = resultFields.textCustomFields[0].errorDetails;
                                logs.add(new Application_Log__c(Application__c = 'DocuSignAPI.updateCustomFields', Description__c = 'Contact: '+contact.Id+'\nFailed to update contact merge field.', Error_Message__c = 'Error: '+errorDetail.errorCode+'-'+errorDetail.message, Type__c= 'Error'));
                            }
                            
                            isRecipientUpdated = true;
                        } 
                        else{
                            logs.add(new Application_Log__c(Application__c = 'DocuSignHelper.updateRecipient', Description__c = 'EnvelopeId: '+envId+'\nRecipient:'+recipient, Error_Message__c = 'Error: '+errorDetails.errorCode+'-'+errorDetails.message, Type__c= 'Error'));
                        }
                    }
                    if(isRecipientUpdated && !envelopeSent){
                        // Update Envelope Status to sent     
                        DocuSignRESTAPI.EnvelopeResult result = DocuSignAPI.sendEnvelope(credential.Account_Id__c, envId);
                        if(result.errorCode == null){
                            envelopeSent = true;
                        }
                        else{
                            logs.add(new Application_Log__c(Application__c = 'DocuSignHelper.getDocuSignRecipientView', Description__c = 'Envelope Id: '+envId, Error_Message__c = 'Failed to update envelope. '+result.errorCode+'-'+result.message, Type__c= 'Error'));
                        }
                    }
                }
                if(envelopeSent){
                    // Create Recipient Embedded url
                    DocuSignRESTAPI.RecipientViewRequest viewRequest = new DocuSignRESTAPI.RecipientViewRequest();
                    viewRequest.userName = contact.Name;
                    viewRequest.authenticationMethod = 'email';
                    viewRequest.clientUserId = '1';
                    viewRequest.email = contact.Email;
                    viewRequest.returnUrl = credential.OnSigningComplete__c;
                    DocuSignRESTAPI.RecipientViewRequestResult viewResult = DocuSignAPI.getRecipientView(credential.Account_Id__c, envId, viewRequest);   
                    if(viewResult.url != null && viewResult.url != ''){
                        // Perform dml after all callouts complete
                        // Update recipient status details in salesforce
                        if(!statusList.isEmpty()){
                            statusList[0].Name = contact.Name;
                            statusList[0].dsfs__DocuSign_Recipient_Email__c = contact.Email;
                            statusList[0].dsfs__DocuSign_Recipient_Title__c = contact.Title;
                            statusList[0].dsfs__Contact__c = contact.Id;
                            if(resultFields != null){
                                 if(resultFields.textCustomFields != null && resultFields.textCustomFields.size() > 0 &&
                                  (resultFields.textCustomFields[0].errorDetails == null ||( resultFields.textCustomFields[0].errorDetails != null && resultFields.textCustomFields[0].errorDetails.errorCode == 'Success'))){
                                    statusList[0].Custom_Field_Id__c = resultFields.textCustomFields[0].FieldId;
                                 }
                            }
                            update statusList[0];
                        }
                        return viewResult.url;
                    }
                    else{
                        logs.add(new Application_Log__c(Application__c = 'DocuSignHelper.getDocuSignRecipientView', Description__c = 'Contact: '+contact.Id+'\nFailed to get recipient view.', Error_Message__c = 'Error: '+viewResult.errorCode+'-'+viewResult.message, Type__c= 'Error'));
                    }
                }
            }
        }
        catch(Exception ex){
            logs.add(new Application_Log__c(Application__c = 'DocuSignHelper.getDocuSignRecipientView', Description__c = 'EnvelopeId: '+envId+'\nContact:'+contact, Error_Message__c = 'Exception: '+ex.getMessage(), Type__c= 'Error'));       
        }
        finally{
             Database.insert(logs, false);
        }
        return '';
    }
}