({
	doInit : function(component, event, helper) {
        var a = component.get("c.getImageList");      
        a.setParams({    
            'carousel': component.get("v.carouselName")
        });
        
        // Create a callback that is executed after
        // the server-side action returns
        a.setCallback(this, function(response) {
            
        if (response.getState() === "SUCCESS") {
        	//console.log(response.getReturnValue());
            //console.log(response);
            var oRes = response.getReturnValue();
            console.log('We have '+oRes.length + ' images');
            if(oRes.length > 0){
                    component.set('v.listOfAllImages', oRes);
            }
        } else {
            console.log(response.getState());
            console.log(response.getError());
        }
        });
        // Add the Apex action to the queue
        $A.enqueueAction(a);
	}})