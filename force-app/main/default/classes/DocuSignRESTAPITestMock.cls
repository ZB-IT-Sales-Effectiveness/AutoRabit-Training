/*********************************************************************************************
    Description: This class test the DocuSignRESTAPI functionality 
    History:
    15/05/2017  Diane Enriquez/Appirio    Initial Development
 **********************************************************************************************/
@isTest
global class DocuSignRESTAPITestMock implements HttpCalloutMock 
{
    global static string error = '';
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"envelopeId":"bar"}');
        
            if(req.getEndPoint().EndsWith('/recipients')){
                DocuSignRESTAPI.RecipientUpdateSummary summary = new DocuSignRESTAPI.RecipientUpdateSummary();
                DocuSignRESTAPI.RecipientUpdateResponse response = new DocuSignRESTAPI.RecipientUpdateResponse();
                response.errorDetails.errorCode = 'success';
                summary.recipientUpdateResults.add(response);
                res.setBody(JSON.serialize(summary));
            }
            else if(req.getEndPoint().EndsWith('/tabs')){
                res.setBody('{ "textTabs": [{"tabId": "234234"}]}');
            }
            else if(req.getEndPoint().EndsWith('/custom_fields')){
                res.setBody('{ "textCustomFields": [{"value": "234234"}]}');
            }
            else if(req.getEndPoint().EndsWith('/views/recipient')){
               res.setBody('{"url":"test"}');
            }
            else if(error != 'updateEnvelope'){
                 res.setBody('{"envelopeId":"bar"}');
            }
            
            res.setStatusCode(200);
        
        
         
        
        return res;
    }
}