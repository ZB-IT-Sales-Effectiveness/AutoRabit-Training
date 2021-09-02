({
   doInitModal : function(component, event, helper) {
      helper.doInitM(component, event, helper);
   },
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      helper.doInitM(component, event, helper);
      helper.getStatesMDT(component, event, helper);
      component.set("v.isOpen", true);
   },
   
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
   
   onChange: function (cmp, evt, helper) {
      alert(cmp.find('select').get('v.value') + ' pie is good.');
   },
   getMessage : function(component, event) {
      //get method paramaters
      var params = event.getParam('arguments');
      if (params) {
         var param1 = params.ChildParam;
         component.set("v.childValueEdit", param1);
      }
   },
   Submit: function(component, event, helper) {
      // Display alert message on the click on the "Like and Close" button from Model Footer 
      // and set set the "isOpen" attribute to "False for close the model Box.

      helper.Submit(component, event, helper);
      // component.set("v.isOpen", false);
   },

 })