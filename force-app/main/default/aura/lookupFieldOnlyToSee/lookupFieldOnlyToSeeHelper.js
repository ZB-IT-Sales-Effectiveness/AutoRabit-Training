({
    doInitH : function (component,event,helper) {
        
        console.log('entro');
        var action = component.get("c.getGPL_Profile");
        action.setParams({
            'first': component.get("v.varFirstName"),
            'last': component.get("v.varLastName"),
            'location': component.get("v.varLocation"),
            'rows': component.get("v.varRows"),
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var details = response.getReturnValue();
            component.set("v.data", details);
        });
        $A.enqueueAction(action);
     },


})