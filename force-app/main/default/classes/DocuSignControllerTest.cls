/*********************************************************************************************
    Description: This class test the DocuSign Controller functionality  
    History:
    15/05/2017  Diane Enriquez/Appirio    Initial Development
 **********************************************************************************************/
@isTest
public without sharing class DocuSignControllerTest {

    
    static Contact contractSigner;
    static Contact contractNoSigner;
    static Contact unlinkedContact;
    static string envStatus = 'Draft';
    public static void createTestData(){
        Account account = new Account(Name = 'Test', Legal_Amendment__c = 'Yes', K_Bill_Cap_Kits__c ='Yes', Item_Clash_Conversion__c = 'No', MDM_SAP_ID__c =  '100');
        insert account;
        List<Contact> contactList = new List<Contact>();
       
        contractSigner = new Contact(LastName = account.Name, Contract_Signatory__c = true, AccountId = account.Id, Email='test@test.com');
        contractNoSigner = new Contact(LastName = account.Name,Contract_Signatory__c = false, AccountId = account.Id, Email='test@test.com');
        unlinkedContact = new Contact(LastName = account.Name, Contract_Signatory__c = true, Email='test@test.com');
        contactList.add(contractSigner);
        contactList.add(contractNoSigner);
        contactList.add(unlinkedContact);
        insert contactList;
       
        DocuSign_Credential__c setting = DocuSign_Credential__c.getOrgDefaults();
        setting.UserName__c = 'Some Value';
        insert setting;
        
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c(dsfs__Company__c = account.Id, dsfs__DocuSign_Envelope_Id__c = 'test', dsfs__Envelope_Status__c = envStatus);
        insert status;
        
        insert new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Id__c = '1', dsfs__Parent_Status_Record__c= status.Id, dsfs__Contact__c = contractSigner.Id, dsfs__envelope_Id__c = 'test', dsfs__DocuSign_Routing_Order__c = 1);
        
    }
    
    public static TestMethod void testRedirectToRecepientView(){
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test');
        ApexPages.CurrentPage().getParameters().put('conId', contractSigner.Id);
        Test.startTest();
        System.assertNotEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
    
    public static TestMethod void testRedirectToRecepientViewEnvSent(){
        envStatus = 'Sent';
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test');
        ApexPages.CurrentPage().getParameters().put('conId', contractSigner.Id);
        Test.startTest();
        System.assertNotEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
    
     public static TestMethod void testRedirectToRecepientViewNoSigner(){
        
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test');
        ApexPages.CurrentPage().getParameters().put('conId', contractNoSigner.Id);
        Test.startTest();
        System.assertEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
    

    
    public static TestMethod void testRedirectToRecepientViewUnlinkContact(){
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test');
        ApexPages.CurrentPage().getParameters().put('conId', unlinkedContact.Id);
        Test.startTest();
        System.assertEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
    
    public static TestMethod void testRedirectToRecepientViewInvalidContact(){
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test');
        ApexPages.CurrentPage().getParameters().put('conId', 'test');
        Test.startTest();
        System.assertEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
    
    public static TestMethod void testRedirectToRecepientViewInvalidEnvId(){
        createTestData();
        DocuSignRESTAPITestMock.error = 'viewRecipient';
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        ApexPages.CurrentPage().getParameters().put('envId', 'test1');
        ApexPages.CurrentPage().getParameters().put('conId', contractSigner.Id);
        Test.startTest();
        System.assertEquals(null, new DocuSignController().redirectToRecepientView());
        Test.stopTest();
    }
}