global class ScheduleTrendingSnapshotsBatch implements Schedulable { 
    
    global void execute(SchedulableContext sc) {     

        ID dataExtractId;
        Datetime dateNow = Datetime.now();
        String currDateString = dateNow.format(UploadTrendingSnapshotsBatch.DATE_FORMAT_STRING);        
        
        if(!Test.isRunningTest()) {
            for(Data_Extract__c dataExtract : [SELECT Id FROM Data_Extract__c WHERE Batch_Job_Id__c =: sc.getTriggerId()]) {
                updateTimestamp(dataExtract.Id);        
                database.executebatch(new UploadTrendingSnapshotsBatch(null, null, null, 1, null, dataExtract.Id, currDateString), 2000);       
            }
         } else {
            for(Data_Extract__c dataExtract : [SELECT Id FROM Data_Extract__c limit 1]) {
                updateTimestamp(dataExtract.Id);        
                database.executebatch(new UploadTrendingSnapshotsBatch(null, null, null, 1, null, dataExtract.Id, currDateString), 2000);       
            }
        }
    } 
    
    @future 
    public static void updateTimestamp(Id dataExtractId) {  
        Data_Extract__c dataExtract = new Data_Extract__c(Id = dataExtractId, Timestamp__c = Datetime.now());
        update dataExtract;
    }
}