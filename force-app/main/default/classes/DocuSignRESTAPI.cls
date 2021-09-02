/*********************************************************************************************
    Description: This class is used to perform DocuSign REST API calls
    History:
    15/05/2017  Diane Enriquez/Appirio    Initial Development
 **********************************************************************************************/
public class DocuSignRESTAPI{
         
    /**
    * Headers to be added on API call
    */
    private Map<String, String> headers = new Map<String, String>();
    
    /**
    * End Point of DocuSign REST API
    */
    private string endPoint;
    
    /**
    * Constructor
    */
    public DocuSignRESTAPI(){
        endPoint = DocuSign_Credential__c.getOrgDefaults().End_Point__c;
    }           
    
    /**
    * This method is used to add headers
    * Params:
    * @name: header name
    * @value: header value
    */ 
    public void addHeader(String name, String value){
        headers.put(name, value);
    } 
    
    /**
    * This method is used to create the envelope
    * Params:
    * @accountId: DocuSign Account Id
    * @parentId: Salesforce object record id whose fields are used in templates
    * @templateId: DocuSign Template Id
    * @signers: List of DocuSign Signer
    * @carbonCopies: List of DocuSign Carbon Copies
    * @supplementalDocs: List of additional Document
    */  
    public EnvelopeResult createEnvelope(String accountId, SObject sObjectInstance, String templateID, List<DocuSignRESTAPI.DocuSignUser> signers, List<DocuSignRESTAPI.DocuSignUser> carbonCopies, List<DocuSignRESTAPI.Document> supplementalDocs){
        
        DocuSignRESTAPI.Envelope envelope = new DocuSignRESTAPI.Envelope();
        envelope.status = 'created';

        /**
        * Add Composite Template on envelope
        */
        DocuSignRESTAPI.CompositeTemplate compositeTemplate = new DocuSignRESTAPI.CompositeTemplate();
        DocuSignRESTAPI.ServerTemplate sTemplate = new DocuSignRESTAPI.ServerTemplate();
        sTemplate.templateId = templateId;
        sTemplate.sequence = '1';
        compositeTemplate.serverTemplates.add(sTemplate);
        
        DocuSignRESTAPI.InlineTemplate iTemplate = new DocuSignRESTAPI.InlineTemplate();
        iTemplate.sequence = '1';
        iTemplate.recipients.signers = signers;
        iTemplate.customFields.textCustomFields.add(new TextCustomField('salesforce', '', sObjectInstance.getSobjectType()+'', 'false', 'true', sObjectInstance.Id));
        iTemplate.recipients.carbonCopies = carbonCopies;
        compositeTemplate.inlineTemplates.add(iTemplate);
        envelope.compositeTemplates.add(compositeTemplate);
        
        for(DocuSignRESTAPI.Document supplementalDoc: supplementalDocs){
            DocuSignRESTAPI.CompositeTemplate composite2 = new DocuSignRESTAPI.CompositeTemplate();
            composite2.document = supplementalDoc;   
            composite2.serverTemplates.add(sTemplate);
            envelope.compositeTemplates.add(composite2);
        }
        HttpResponse res = sendHttpRequest('POST', endPoint + accountId+'/envelopes?merge_roles_on_draft=true', headers, JSON.serialize(envelope));
        return (DocuSignRESTAPI.EnvelopeResult)JSON.deserialize(res.getBody(), DocuSignRESTAPI.EnvelopeResult.class);
    }
    
    /**
    * This method is used to create the recipient view
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @requestData: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.RecipientViewRequestResult getRecipientView(String accountId, String envelopeId, RecipientViewRequest requestData){
        HttpResponse res = sendHttpRequest('POST', endPoint + accountId+'/envelopes/'+envelopeId+'/views/recipient', headers, JSON.serialize(requestData));
        return (DocuSignRESTAPI.RecipientViewRequestResult)JSON.deserialize(res.getBody(), DocuSignRESTAPI.RecipientViewRequestResult.class);
    }
    
    /**
    * This method is used to update the recipient view
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @requestData: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.RecipientUpdateSummary updateRecipient(String accountId, String envelopeId, Recipient recipients){
        HttpResponse res = sendHttpRequest('PUT', endPoint + accountId+'/envelopes/'+envelopeId+'/recipients', headers, JSON.serialize(recipients));
        
        return (DocuSignRESTAPI.RecipientUpdateSummary)JSON.deserialize(res.getBody(), DocuSignRESTAPI.RecipientUpdateSummary.class);
    }
    
    /**
    * This method is used to update custom fields
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @requestData: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.CustomFields2 createCustomFields(String accountId, String envelopeId, CustomFields cFields){
        HttpResponse res = sendHttpRequest('POST', endPoint + accountId+'/envelopes/'+envelopeId+'/custom_fields', headers, JSON.serialize(cFields));
        
        return (DocuSignRESTAPI.CustomFields2)JSON.deserialize(res.getBody(), DocuSignRESTAPI.CustomFields2.class);
    }


 /**
    * This method is used to update custom fields
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @requestData: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.CustomFields2 deleteCustomFields(String accountId, String envelopeId, CustomFields2 cFields){
        HttpResponse res = sendHttpRequest('DELETE', endPoint + accountId+'/envelopes/'+envelopeId+'/custom_fields', headers, JSON.serialize(cFields));
        
        return (DocuSignRESTAPI.CustomFields2)JSON.deserialize(res.getBody(), DocuSignRESTAPI.CustomFields2.class);
    }
    
    /**
    * This method is used to update custom fields
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @requestData: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.CustomFields2 updateCustomFields(String accountId, String envelopeId, CustomFields2 cFields){
        HttpResponse res = sendHttpRequest('PUT', endPoint + accountId+'/envelopes/'+envelopeId+'/custom_fields', headers, JSON.serialize(cFields));
        
        return (DocuSignRESTAPI.CustomFields2)JSON.deserialize(res.getBody(), DocuSignRESTAPI.CustomFields2.class);
    }

     /**
    * This method is used to change status of envelope from created to sent
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @envelope: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.EnvelopeResult sendEnvelope(String accountId, String envelopeId){
        Envelope envelope = new Envelope();
        envelope.status = 'sent';
       
        HttpResponse res = sendHttpRequest('PUT', endPoint + accountId+'/envelopes/'+envelopeId, headers, JSON.serialize(envelope));
        return (DocuSignRESTAPI.EnvelopeResult)JSON.deserialize(res.getBody(), DocuSignRESTAPI.EnvelopeResult.class);
    }
    
    public DocuSignRESTAPI.Tabs getTitleTabId(String accountId, String envelopeId, String recipientId){
        HttpResponse res = sendHttpRequest('GET', endPoint + accountId+'/envelopes/'+envelopeId+'/recipients/'+recipientID+'/tabs', headers, null);
        return (DocuSignRESTAPI.Tabs)JSON.deserialize(res.getBody(), DocuSignRESTAPI.Tabs.class);
    }
    
     /**
    * This method is used to change status of envelope from created to sent
    * Params:
    * @accountId: DocuSign Account Id
    * @envelopeId: DocuSign Envelope Id for which view to be created
    * @envelope: Recipient details for which view to be created
    */ 
    public DocuSignRESTAPI.EnvelopeResult updateTab(String accountId, String envelopeId, String recipientId, Tabs tabs){
        HttpResponse res = sendHttpRequest('PUT', endPoint + accountId+'/envelopes/'+envelopeId+'/recipients/'+recipientId+'/tabs', headers, JSON.serialize(tabs));
        return (DocuSignRESTAPI.EnvelopeResult)JSON.deserialize(res.getBody(), DocuSignRESTAPI.EnvelopeResult.class);
    }
    
    /**
    * This method is used to send http calls
    * Params:
    * @method: HTTP METHOD can be get, post etc
    * @endPoint: End Point http call
    * @headers: Http headers
    * @body: Request body
    */    
    private HttpResponse sendHttpRequest(String method, String endPoint, Map<String, String> headers, String body){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        if(body != null){
            req.setBody(body);
            system.debug(body);
        }
        for(String key: headers.keyset()){
            req.setHeader(key, headers.get(key));
        }
        
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        if(res.getStatusCode() != 201 && res.getStatusCode() != 200){
            throw new CustomException('Unsuccessful callout. Error Body:'+res.getBody());
        }
        return res;
    }
    
    /**
    * Dcusign Envelope Info
    */   
    public class Envelope{
         public string status;
         public string emailSubject;
         public List<CompositeTemplate> compositeTemplates;
         public Recipient recipients;
         public Envelope(){
             compositeTemplates = new List<CompositeTemplate>();
             recipients = new Recipient();
         }
     }   

    /**
    * DocuSign Document Info
    */ 
    public class document{
        public string documentId;
        public string name;
        public string documentBase64;
        public Boolean includeInDownload;
        public string display;
        public string signerMustAcknowledge;
        public string order;
        public string documentGroup;
        public string fileExtension;
        public document(){
            documentGroup = 'content';
        }
    }
    
    /**
    * Server Template Info
    */ 
    public class ServerTemplate{
        public string sequence;
        public string templateId;
    }
    
    /**
    * Inline Template Info
    */
    public class InlineTemplate{
        public string sequence;
        public Recipient recipients;
        public CustomFields customFields;
        public InlineTemplate(){
            recipients = new Recipient();
            customFields = new CustomFields();
        }
    }
    
    /**
    * DocuSign Recipient Info
    */
    public class DocuSignUser{
        public string email;
        public string name;
        public string roleName;
        public string clientUserId;
        public string routingOrder;
        public string recipientId;
        public Tabs tabs;
        public string signingGroupId;
        public string signingGroupName;
        
        
        public DocuSignUser(){
            tabs = new Tabs();
           
        }
    }
    
    /**
    * List of Recipient
    */
    public class Recipient{
        public DocuSignUser[] signers;
        public DocuSignUser[] carbonCopies;
       
        public Recipient(){
            signers = new List<DocuSignUser>();
            carbonCopies = new List<DocuSignUser>();
        }
    }
    
    /**
    * Composite Template Info
    */
    public class CompositeTemplate{
        public List<ServerTemplate> serverTemplates;
        public List<InlineTemplate> inlineTemplates;
        public Document document;
        public CompositeTemplate(){
            serverTemplates = new List<ServerTemplate>();
            inlineTemplates = new List<InlineTemplate>();
        }
    }
    
    /**
    * Custom Field Info
    */
    public class CustomFields{
        public List<TextCustomField> textCustomFields;
        public CustomFields(){
            textCustomFields = new List<TextCustomField>();
        }
    }

    /**
    * Custom Field Info
    */
    public class CustomFields2{
        public List<TextCustomField2> textCustomFields;
        public CustomFields2(){
            textCustomFields = new List<TextCustomField2>();
        }
    }
    
    /**
    * Text Custom Field Info
    */
    public class TextCustomField{
        public string configurationType;
        //public string fieldId;
        public string name;
        public string required;
        public string show;
        public string value;
        public ErrorDetails errorDetails;
        public TextCustomField(string configurationType, string fieldId, string name, string required, string show, string value){
           this.configurationType = configurationType;
           //this.fieldId = fieldId;
           this.name = name;
           this.required = required;
           this.show = show;
           this.value = value;
        }
    }
    
     public class TextCustomField2{
        public string configurationType;
        public string fieldId;
        public string name;
        public string required;
        public string show;
        public string value;
        public ErrorDetails errorDetails;
        public TextCustomField2(string configurationType, string fieldId, string name, string required, string show, string value){
           this.configurationType = configurationType;
           this.fieldId = fieldId;
           this.name = name;
           this.required = required;
           this.show = show;
           this.value = value;
        }
    }
    
    /**
    * Holds Envelope Result
    */  
    public class EnvelopeResult{
        public string envelopeId;
        public string uri;
        public string statusDateTime;
        public string status;
        public string errorCode;
        public string message;
     } 
     
    /**
    * Holds Recipient View Request Info
    */  
    public class RecipientViewRequest{ 
        public string authenticationMethod;
        public string clientUserId;
        public string email;
        public string returnUrl;
        public string userName;
    }
    
    /**
    * Holds Recipient View Request Result Info
    */  
    public class RecipientViewRequestResult{ 
        public string url;
        public string errorCode;
        public string message;
    }
    
    public class Tabs{
        public List<Tab> titleTabs;
        public List<Tab> textTabs;
        public Tabs(){
            titleTabs = new List<Tab>();
            textTabs = new List<Tab>();
        }
    }
    
    public class Tab{
        public string tabLabel;
        public string value;
        public string recipientId;
        public string tabId;
        public Tab(string tabLabel, string value, string recipientId){
            this.tabLabel = tabLabel;
            this.value = value;
            this.recipientId = recipientId;
        }
    }
    public class RecipientUpdateSummary{
        public List<RecipientUpdateResponse> recipientUpdateResults;
        public RecipientUpdateSummary(){
            recipientUpdateResults = new List<RecipientUpdateResponse>();
        }
    }
    
    public class RecipientUpdateResponse{
        public ErrorDetails errorDetails;
        public string recipientId;
        public RecipientUpdateResponse(){
             errorDetails = new errorDetails();
        }
    }
    
    public class ErrorDetails{
        public string errorCode;
        public string message;
    }
 }