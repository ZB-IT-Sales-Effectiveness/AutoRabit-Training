({
    doInitM : function (component,event,helper) {
        
        var childValue = component.get("v.childValue");
        var recId = childValue.Id;
        console.log(recId);
        var action = component.get("c.getGPL_Location");
        action.setParams({
            "recordId" : recId
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var details = response.getReturnValue();
            component.set("v.dataTable", details);
        });
        $A.enqueueAction(action);
        
        let foto = component.get("v.childValue.Photo__c");
        let includPhoto = foto.includes('"/servlet/servlet.FileDownload?file=\"');//no contiene foto
        component.set("v.validPhoto", !includPhoto);
    },
    getStatesMDT : function (component,event,helper) {
        
        console.log('entro getStatesMDT');
        var action = component.get("c.getStatesMDT");
        action.setParams({
            'Country': 'USA',
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var details = response.getReturnValue();
            component.set("v.State", details);
        });
        $A.enqueueAction(action);
     },
     Submit: function (component,event,helper){
        
        // console.log('Padre')
        // console.log('entro updateProfileDetails');
        
        let child = component.get("v.childValueEdit");
        console.log(JSON.stringify(child));
        let recId = child.Id;
        var action = component.get("c.updateProfileDetails");
        action.setParams({
            "recordId" : recId,
            'states': child
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var details = response.getReturnValue();
            component.set("v.State", details);
        });
        $A.enqueueAction(action);

     }

})