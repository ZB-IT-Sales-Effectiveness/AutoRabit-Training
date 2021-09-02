public class MV_Util {
    
public static List<String> GetAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
    List<String> names = new List<String>();
    //Schema.SObjectType objType = Opportunity.SObjectType;
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    //System.debug(infos);
    
    // If there are 2 or more RecordTypes...
    if (infos.size() > 1) {
        for (RecordTypeInfo i : infos) {
           if (i.getName() == 'ROSA Knee')
           {
               if (i.isAvailable())          
               {
                    //names.add(i.getName());
                    System.debug('has access to Record Type : '+i.getName());
               }
                else
                {
                    names.add(i.getName());
                    System.debug('has NO access to Record Type : '+i.getName());
                }
            }
        }
    } 
    // Otherwise there's just the Master record type,
    // so add it in, since it MUST always be available
    else names.add(infos[0].getName());
    return names;
}
    
}