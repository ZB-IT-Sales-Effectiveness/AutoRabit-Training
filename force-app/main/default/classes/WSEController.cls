public with sharing class WSEController {
    public WSEController() {

    }

    @AuraEnabled
    public static List<WSE__c> getWSERecordsForWeek(Decimal weekNo, String TerrId){
        try {
            List<WSE__c> lstWSE = [Select Effective_Date__c,Id,Name,Owner.Name,Prior_Mnth_WSE__c,Prior_Qtr_WSE__c,WSE_Mnth__c,WSE_Qtr__c,Product__c,Status__c,Target_Mnth__c,Target_Qtr__c,Territory2Id__c,Territory__c,Vs_Prior_WSE_Amt_Mnth__c,Vs_Prior_WSE_Amt_Qtr__c,Vs_Prior_WSE_Pct_Mnth__c,Vs_Prior_WSE_Pct_Qtr__c,Vs_Target_Amt_Mnth__c,Vs_Target_Amt_Qtr__c,Vs_Target_Pct_Mnth__c,Vs_Target_Pct_Qtr__c,Week_Number__c,WSE_Vs_PY_ADS_Mnth__c,WSE_Vs_PY_ADS_Qtr__c,WSE_Vs_PY_Day_Adj_Mnth__c,WSE_Vs_PY_Day_Adj_Qtr__c from WSE__c where Week_Number__c = :weekNo and Territory2Id__c = :TerrId];

            return lstWSE;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static List<String> getWSEWeekNoList(){
        try {
            List<WSE__c> lstWSE = [Select Id, Effective_Date__c, Name, Week_Number__c from WSE__c order by Effective_Date__c desc];
            
            Set<String> s = new Set<String>();
            List<String> effDtList = new List<String>();
            
            System.debug('There are '+lstWSE.size() + ' records in WSE');

            for (WSE__c w : lstWSE) {
                Datetime dt = w.Effective_Date__c;                
                s.add(dt.format('MM-dd-yyyy'));
            }
            
            effDtList.addAll(s);
            System.debug('Effective Date List Array: '+effDtList);
            return effDtList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Id,String> getWSETerrList(){
        try {
            List<WSE__c> lstWSE = [Select Id, Effective_Date__c, Name, Week_Number__c, Territory2Id__c, Territory__c from WSE__c order by Effective_Date__c desc];
            
            Map<Id, String> terr = new Map<Id,String>();

            for (WSE__c w : lstWSE) {
                if (!terr.containsKey(w.Territory2Id__c)) {
                    terr.put(w.Territory2Id__c, w.Territory__c);
                }
            }

            return terr;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}