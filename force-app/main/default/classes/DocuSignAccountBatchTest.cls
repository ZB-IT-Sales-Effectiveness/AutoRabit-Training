/*********************************************************************************************
    Description: This class test the DocuSignAccountBatch functionality to create DocuSign 
    Status records with intended Recipients
    History:
    15/05/2017  Diane Enriquez/Appirio    Initial Development
 **********************************************************************************************/
@isTest
public with sharing class DocuSignAccountBatchTest {
    public static void createTestData(){
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 5; i++){
            accountList.add(new Account(Name = 'Test'+i, Legal_Amendment__c = 'Yes', K_Bill_Cap_Kits__c =((i/2) == 0?'Yes':'No'), Item_Clash_Conversion__c = ((i/2) == 0?'Yes':'No'), MDM_SAP_ID__c =  '100'+i));
        }
        
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
        List<Attachment> attachmentList = new List<Attachment>();
        Integer i = 0;
        for(Account account: accountList){
            contactList.add(new Contact(LastName = account.Name, Contract_Signatory__c = true, AccountId = account.Id, Email='test@test.com'));
            teamMemberList.add(new AccountTeamMember(UserId = UserInfo.getUserId(), AccountAccessLevel='Edit', AccountId = account.Id, TeamMemberRole = 'Distributor'));
            attachmentList.add(new Attachment(ParentId = account.Id, Name = '100'+(i++)+'_'+((i/2) == 0?'Yes':'No'), body = Blob.valueOf('12123')));
        }
        insert contactList;
        insert teamMemberList;
        insert attachmentList;
        DocuSign_Credential__c setting = DocuSign_Credential__c.getOrgDefaults();
        setting.UserName__c = 'Some Value';
        insert setting;
        
        List<DocuSign_Template__c> templateList = new List<DocuSign_Template__c>();
        templateList.add(new DocuSign_Template__c(Name = '1', Template_Id__c = 'DocuSign Template Id', Logic__c = ' createddate = today '));
        templateList.add(new DocuSign_Template__c(Name = '2', Template_Id__c = 'DocuSign Template Id', Logic__c = ' createddate = today '));
        insert templateList;
    }
    
    public static TestMethod void testRedirectToRecepientView(){
        createTestData();
        Test.setMock(HttpCalloutMock.class, new DocuSignRESTAPITestMock());
        Test.startTest();
        Database.executeBatch(new DocuSignAccountBatch(), 5);
        Test.stopTest();
        system.AssertNotEquals(0, [select count() from dsfs__DocuSign_Status__c]);
    }
}