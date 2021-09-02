/*********************************************************************************************
Description: This class is the controller for Visualforce page, XA2DCS, which opens the
DocuSign Recipient view for the first signer/Signer 1
History:
15/05/2017   Diane Enriquez/Appirio    Initial Development
**********************************************************************************************/
public without sharing class DocuSignController {
    
    
    /**
    * Redirect user to the DocuSign Recipient view
    * Required envId and conId in the url
    */
    public PageReference redirectToRecepientView(){
        String envelopeId = ApexPages.CurrentPage().getParameters().get('envId');
        String contactId = ApexPages.CurrentPage().getParameters().get('conId');
        String errorMsg = '';
        if(envelopeId != null && envelopeId != '' && contactId != null && contactID != ''){
            List<Contact> contactList = [select name, email, AccountId, title, Contract_Signatory__c from contact where id =: contactId];
            // Get Signer 1 details
            List<dsfs__DocuSign_Recipient_Status__c> statusList = [select name, Title_Tab_Id__c, dsfs__Recipient_Status__c, 
                                                                    dsfs__Parent_Status_Record__r.dsfs__Envelope_status__c, 
                                                                    dsfs__Parent_Status_Record__r.dsfs__Company__c,
                                                                    dsfs__DocuSign_Recipient_Email__c, 
                                                                    dsfs__DocuSign_Recipient_Title__c,
                                                                    dsfs__Contact__r.Name,
                                                                    dsfs__Contact__r.Email,
                                                                    dsfs__Contact__r.Title 
                                                                from dsfs__DocuSign_Recipient_Status__c 
                                                                where dsfs__Envelope_Id__c =: envelopeId
                                                                and dsfs__DocuSign_Routing_Order__c = 1];
            
            
            if(!contactList.isEmpty()){
                if(!statusList.isEmpty()){
                    if(statusList[0].dsfs__Parent_Status_Record__r.dsfs__Company__c == contactList[0].AccountId){
                        if(contactList[0].Contract_Signatory__c){
                            Contact signer = contactList[0];
                            if(statusList[0].dsfs__Parent_Status_Record__r.dsfs__Envelope_status__c == 'sent'){
                                if(statusList[0].dsfs__Recipient_Status__c != 'Completed' && statusList[0].dsfs__Contact__c != contactList[0].Id){
                                    errorMsg = 'An individual within your organization has started the signature process for this document.  If you feel this was done in error, please contact integration.communication@zimmerbiomet.com.';
                                }
                                else{
                                    signer = statusList[0].dsfs__Contact__r;
                                }
                                
                            }
                            if(errorMsg == ''){
                                DocuSignHelper DocuSign = new DocuSignHelper();
                                String url = DocuSign.getDocuSignRecipientView(envelopeId, signer);
                                if(url != null && url != ''){ 
                                    return new PageReference(url);
                                }
                                else{
                                     errorMsg = 'Some Error Occured. Please try again later';
                                }
                            }
                        }
                        else{
                             errorMsg = 'This Contact doesn\'t have permission to fill out the DocuSign';
                        }
                    }
                    else{
                        errorMsg = 'This Contact doesn\'t belong to the Company for which this DocuSign was created';
                    }
                }
                else{
                    errorMsg = 'Invalid Envelope Id';
                }
            }
            else{
                errorMsg = 'Invalid Contact Id';
            }
        }
        if(errorMsg != ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
        }
        return null;
    } 
}