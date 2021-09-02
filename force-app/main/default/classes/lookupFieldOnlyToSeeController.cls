/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class lookupFieldOnlyToSeeController {
    public lookupFieldOnlyToSeeController() {

    }

    @AuraEnabled
    public static List<GPL_Profile__c> getGPL_Profile(String first, String last, String location, Integer rows){
        System.debug(first);
        System.debug(last);
        System.debug(location);
        System.debug(rows);
        
        String xf = '%' + first + '%';
        String yl = '%' + last + '%';
        String zl = '%' + location + '%';
        String query ='SELECT Id, FirstName__c, LastName__c, Locations__c, Address__c, Board_Certificates__c, Contact__c, Contact_Title__c, CurrencyIsoCode, Devices__c, Email_Address__c, Facebook__c, Fellowship__c, GPL_Physician_Locator__c, Name, Groups__c, Honors__c, Inactive__c, Languages__c, LinkedIn__c, Location_Count__c, MasterId__c, MedicalSchool__c, Middle_Name__c, Name__c, Parent__c, ParentId__c, Photo__c, PhotoId__c, Picture_Id__c, PreferredFirstName__c, PreferredName__c, Procedures__c, Publications__c, Residency__c, Salutation__c, Specialties__c, Specialty_Type__c, Suffix__c, Surgeon_Country__c, Surgical_Interests__c, Twitter__c, Under_Graduate__c, Username__c, Years_in_Practice__c, YouTube__c FROM GPL_Profile__c';          
        // query  += ' WHERE (FirstName__c LIKE :xf OR LastName__c LIKE :yl)'; 
        query  += ' LIMIT :rows'; 
        System.debug('>>> query:: '+ query);
        List<GPL_Profile__c> GPL_Profile = database.query(query); 

        // List<GPL_Profile__c> GPL_Profile = [SELECT 	Address__c, Board_Certificates__c, Contact__c, Contact_Title__c, CurrencyIsoCode, Devices__c, Email_Address__c, Facebook__c, Fellowship__c, FirstName__c, GPL_Physician_Locator__c, Name, Groups__c, Honors__c, Inactive__c, Languages__c, LastName__c, LinkedIn__c, Location_Count__c, Locations__c, MasterId__c, MedicalSchool__c, Middle_Name__c, Name__c, Parent__c, ParentId__c, Photo__c, PhotoId__c, Picture_Id__c, PreferredFirstName__c, PreferredName__c, Procedures__c, Publications__c, Residency__c, Salutation__c, Specialties__c, Specialty_Type__c, Suffix__c, Surgeon_Country__c, Surgical_Interests__c, Twitter__c, Under_Graduate__c, Username__c, Years_in_Practice__c, YouTube__c 
        // FROM GPL_Profile__c 
        // WHERE (FirstName__c LIKE :xf OR LastName__c LIKE :yl)
        // LIMIT :rows];
        List<GPL_Profile__c> profile = new List<GPL_Profile__c>();
        profile.addAll(GPL_Profile);
        return profile;

    }

    @AuraEnabled
    public static List<GPL_Location__c> getGPL_Location(Id recordId){
 
        String query ='SELECT Id, Area_Code__c, City__c, Country__c, CurrencyIsoCode, Fax__c, Geolocation__c, GPL_Location_18_Digit_Id__c, Name, LastModifiedById, Latitude__c, Location_Type__c, Longitude__c, Name__c, Phone__c, PostalCode__c, Services__c, State__c, Street__c, Website__c FROM GPL_Location__c';          
        query  += ' WHERE GPL_Profile__r.Id = :recordId'; 
        System.debug('>>> query:: '+ query);
        List<GPL_Location__c> GPL_Location = database.query(query); 

        List<GPL_Location__c> location = new List<GPL_Location__c>();
        location.addAll(GPL_Location);
        return location; 
    }

    @AuraEnabled
    public static List<States__mdt> getStatesMDT(String Country){
 
        String query ='SELECT Id,Country__c, Country__r.Country_code__c, Country__r.label, State_code__c, label, State_Label__c from States__mdt';          
        query  += ' WHERE Country__r.label = :Country'; 
        System.debug('>>> query:: '+ query);
        List<States__mdt> States = database.query(query); 

        List<States__mdt> ListStates = new List<States__mdt>();
        ListStates.addAll(States);
        return ListStates;

    }

    @AuraEnabled
    public static string updateProfileDetails(Id recordId, GPL_Profile__c states) {
        
        System.debug('id ' + recordId);
        System.debug('states ');
        System.debug(states);
        try {
            update(states);
            return ' inspections completed sucessfully.';
        } catch (Exception e) {
            return 'Error: ' + e;
        }  
    }

}