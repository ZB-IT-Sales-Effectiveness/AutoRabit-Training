({    
    refresh: function(component, event, helper){
        let reloadPage = event.getParam('reloadPage');
 
        if(reloadPage){
            console.log('Aura Component - Triggering Reload - Refresh');
            let workspaceAPI = component.find("myworkspace")
            workspaceAPI.getFocusedTabInfo().then(function(response){
                let focusedTabId = response.tabId;
                workspaceAPI.refreshTab({
                    tabId: focusedTabId,
                    includeAllSubtabs: true
                });
            })
            .catch(function(error){
                console.log(error);
                // run other error handling 
            })
        }
    },
});