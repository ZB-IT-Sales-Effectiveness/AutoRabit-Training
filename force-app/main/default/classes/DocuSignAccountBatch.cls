/*********************************************************************************************
Description: This batch is used to create envelopes for Accounts with Legal Amendment is Yes
             and have at least one contact with Contract Signatory is TRUE. We have rules 
             stored in the 'DocuSign Template' Custom Setting, where we associate the DocuSign
             Template Id and Logic (criteria).
             Batch is executed once for each Custom Setting record.
             Batch size should be 5 since only 10 call outs can be performed in execute method
History:
15/05/2017   Diane Enriquez    Initial Development
**********************************************************************************************/
global class DocuSignAccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    /**
    * Constant Variables
    */
    static final string YES = 'Yes';
    static final string NO = 'No';
    static final string ATTACHMENT_A_XLSX = '_Attachment_A-Product_Number_Changes.xlsx';
    static final string ATTACHMENT_B_XLSX = '_Attachment_B-New_Catalog_Numbers_CAP_Billings.xlsx';
    static final Integer BATCH_MAX_SIZE = 5;
    static final string DISTRIBUTOR = 'Distributor';
    
    /**
    * Current Rule Number executing
    */
    Integer currentRule; 
    
    /**
    * Batch Start Query
    */
    String query = 'Select Id, Name, K_Bill_Cap_Kits__c, Item_Clash_Conversion__c, MDM_SAP_ID__c, '+
                           +'(Select Id, User.Name, User.Email '
                             +' from AccountTeamMembers  '
                             +' Where TeamMemberRole = \''+DISTRIBUTOR+'\'),'
                             +' (Select Id, Email, Name, Title, Contract_Signatory__c '
                             +'       from Contacts '
                             +'       where Contract_Signatory__c = true '
                             +'           and Email != null order by lastmodifieddate desc limit 1) '
                         +'from Account where Legal_Amendment__c = \''+YES+'\'';
    
    /**
    * Constructor
    */ 
    global DocuSignAccountBatch(){
        currentRule = 1;
    }
    
    /**
    * Constructor
    */
    global DocuSignAccountBatch(Integer nextRule){
        currentRule = nextRule;
    }
    
    /**
    * Batch Start
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DocuSign_Template__c template = DocuSign_Template__c.getInstance(String.valueOf(currentRule));
        if(template != null && template.Logic__c != null){
            query = query + ' and '+template.Logic__c;
        }
        return Database.getQueryLocator(query);
    }

    /**
    * Batch Execute
    */
    global void execute(Database.BatchableContext bc, List<Account> accountList){
        
        /**
        * Throw Error if batch size is greater then BATCH_MAX_SIZE
        */
        if(accountList.size() > BATCH_MAX_SIZE){
            throw new CustomException(Label.DocuSign_Batch_Size_Limit_Msg);
        }

        List<dsfs__DocuSign_Status__c> DocuSignList = new List<dsfs__DocuSign_Status__c>();
        List<dsfs__DocuSign_Recipient_Status__c> recipientList = new List<dsfs__DocuSign_Recipient_Status__c>(); 
        Map<String, dsfs__DocuSign_Status__c> docMap = new Map<String, dsfs__DocuSign_Status__c>();                                         
        DocuSignHelper dHelper = new DocuSignHelper();
        DocuSign_Template__c template = DocuSign_Template__c.getInstance(String.valueOf(currentRule));
        
        Map<ID, List<Attachment>> accountAttachments = new Map<Id, List<Attachment>>();
        
        DocuSign_Credential__c credential = DocuSign_Credential__c.getOrgDefaults();
        
        DocuSignRESTAPI DocuSignAPI = new DocuSignRESTAPI();
        DocuSignAPI.addHeader('X-DocuSign-Authentication', dHelper.createDocuSignAuthHeader());
        DocuSignAPI.addHeader('Content-Type', 'Application/json');
        List<Application_Log__c> logs = new List<Application_Log__c>();
        
        for(Attachment attachment: [Select Id, Name, Body,ParentId from Attachment where parentId in: accountList]){
            if(!accountAttachments.containsKey(attachment.parentId)){
                accountAttachments.put(attachment.ParentID, new List<Attachment>());
            }
            accountAttachments.get(attachment.ParentId).add(attachment);
        }
        for(Account account: accountList){
            try{
            if(account.contacts.size() == 0){
                continue;
            }
            /**
            * Get Recipient List 
            */
            DocuSignRESTAPI.DocuSignUser[] recipientArray = new List<DocuSignRESTAPI.DocuSignUser>();//dHelper.getRecipientList(account.contacts);
            DocuSignRESTAPI.DocuSignUser dUser = dHelper.getRecipient(account.Name, 'anysigner@gmail.com', '', '1' ,'Signer 1','1');
            //DocuSignRESTAPI.DocuSignUser dUser = dHelper.getRecipient('Test Group API', '', '', '1' ,'Signer 1','1');
            dUser.clientUserId = '1';
            //dUser.signingGroupName = 'Test Group API';
            //dUser.signingGroupId = '27306';
            recipientArray.add(dUser);
            
            recipientArray.add(dHelper.getRecipient(credential.Recipient_Name__c, credential.Recipient_Email__c, credential.Recipient_Title__c, (account.contacts.size() + 1)+'' ,'Signer 2','2'));
            
            /**
            * Get Carbon Copy List which is the Distributor Account Team member
            */
            DocuSignRESTAPI.DocuSignUser[] ccRecipient = dHelper.getCarbonCopyList(account.AccountTeamMembers);
           
            List<DocuSignRESTAPI.Document> supplementalDocs = new List<DocuSignRESTAPI.Document>();
            
            /**
            * Add Supplemental Documents based on Item Clash Conversion and K-Bill (Cap Kits)
            */
            Integer docId = 10;
            Set<String> attachmentNames = new Set<String>();
            if(account.Item_Clash_Conversion__c == YES){
                attachmentNames.add(account.MDM_SAP_ID__c + ATTACHMENT_A_XLSX);
            }
            if(account.K_Bill_Cap_Kits__c == YES){
                attachmentNames.add(account.MDM_SAP_ID__c + ATTACHMENT_B_XLSX);
            }
            if(accountAttachments.containsKey(account.Id)){
                for(Attachment attachment: accountAttachments.get(account.Id)){
                    if(attachmentNames.contains(attachment.Name)){
                        supplementalDocs.add(dHelper.createDocumentInstance(attachment, (docId++)+''));
                     }
                }
            }
            
            DocuSignRESTAPI.EnvelopeResult eStatus = DocuSignAPI.createEnvelope(credential.Account_Id__c, account, template.Template_Id__c, recipientArray, ccRecipient, supplementalDocs);
            
            /**
            * If envelope id is not generated then create error log
            */
            if(eStatus.errorCode != null && eStatus.errorCode != ''){
                logs.add(new Application_Log__c(Application__c = 'DocuSign Account Batch', Description__c = 'Error in Account: '+account.Id, Error_Message__c = eStatus.message, Type__c= 'Error'));
            }
            else{
            
                // Get Tab ID
                
                DocuSignRESTAPI.Tabs tabs = DocuSignAPI.getTitleTabId(credential.Account_Id__c, eStatus.EnvelopeId, '1');
                String tabId = '';
                for(DocusignRESTAPI.Tab tab: tabs.textTabs){
                    if(tab.tabLabel == 'ContactTitle'){
                        tabId = tab.tabId;
                    }
                }                
                system.debug(tabs);
                /**
                * Create DocuSign Status records in Salesforce
                */
                dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c(dsfs__Company__c = account.Id,
                                                         dsfs__DocuSign_Envelope_ID__c = eStatus.EnvelopeID
                                                    );
                DocuSignList.add(docStatus);
                docMap.put(eStatus.EnvelopeID, docStatus);
                
                for(Integer i = 0; i < recipientArray.size(); i++){
                    DocuSignRESTAPI.DocuSignUser recipient = recipientArray[i];
                    recipientList.add(new dsfs__DocuSign_Recipient_Status__c(
                                          
                                          dsfs__Envelope_Id__c = eStatus.EnvelopeID,
                                          dsfs__DocuSign_Recipient_Email__c = recipient.Email,
                                          dsfs__DocuSign_Recipient_Id__c = recipient.recipientId,
                                          Name = recipient.name, 
                                          dsfs__Account__c = account.Id,
                                          Title_Tab_Id__c = (recipient.recipientId == '1' ? tabId: null),
                                          dsfs__DocuSign_Routing_Order__c = recipient.RoutingOrder != null ? Decimal.valueof(recipient.RoutingOrder): null));  
                
                }   
                for(DocuSignRESTAPI.DocuSignUser recipient: ccRecipient){
                    recipientList.add(new dsfs__DocuSign_Recipient_Status__c(
                                          
                                          dsfs__Envelope_Id__c = eStatus.EnvelopeID,
                                          dsfs__DocuSign_Recipient_Email__c = recipient.Email,
                                          dsfs__DocuSign_Recipient_Id__c = recipient.recipientId,
                                          Name = recipient.name,                                         
                                          dsfs__DocuSign_Routing_Order__c = recipient.RoutingOrder != null ? Decimal.valueof(recipient.RoutingOrder): null));  
                
                } 
            }                                                      
        }
        catch(Exception ex){
                logs.add(new Application_Log__c(Application__c = 'Docusign Account Batch', Description__c = 'Error in Account: '+account.Id, Error_Message__c = ex.getMessage(), Type__c= 'Error'));
            }                                                
        }
        /**
        * If DML fails then create Application Log
        */
        List<Database.SaveResult> docuSaveResults = Database.Insert(DocuSignList, false);
        for(dsfs__DocuSign_Recipient_Status__c recipient: recipientList){
            if(docMap.get(recipient.dsfs__Envelope_Id__c) != null && docMap.get(recipient.dsfs__Envelope_Id__c).Id != null){
                recipient.dsfs__Parent_Status_Record__c = docMap.get(recipient.dsfs__Envelope_Id__c).Id;
            }
        }
        List<Database.SaveResult> reciSaveResults = Database.Insert(recipientList, false);        
        for(Integer i =0;i<docuSaveResults.size(); i++){
            Database.SaveResult sResult = docuSaveResults[i];
            if(!sResult.isSuccess()){
                logs.add(new Application_Log__c(Application__c = 'DocuSign Account Batch', Description__c = 'Failed to create DocuSign status record for Account Id: '+DocuSignList[i].dsfs__Company__c, Error_Message__c = sResult.getErrors()[0].getMessage(), Type__c= 'Error'));
            }
        }
        for(Integer i =0;i<reciSaveResults.size(); i++){
            Database.SaveResult sResult = reciSaveResults[i];
            if(!sResult.isSuccess()){
                logs.add(new Application_Log__c(Application__c = 'DocuSign Account Batch', Description__c = 'Failed to create DocuSign status record for Contact: '+recipientList[i].dsfs__Contact__c, Error_Message__c = sResult.getErrors()[0].getMessage(), Type__c= 'Error'));
            }
        }
        List<Database.SaveResult> saveResults = Database.Insert(logs, false);
    }    
    
    /**
    * Batch Finish
    */
    global void finish(Database.BatchableContext bc){
        /**
        * Execute next rule if defined in custom setting
        */
        Integer nextRule = currentRule + 1;
        DocuSign_Template__c template = DocuSign_Template__c.getInstance(String.valueOf(currentRule + 1));
        if(template != null){
            Database.executeBatch(new DocuSignAccountBatch(currentRule + 1), BATCH_MAX_SIZE);
        }
    }    

}