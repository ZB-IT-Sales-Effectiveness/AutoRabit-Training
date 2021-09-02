({
    doInitHH : function (component,event,helper) {
        helper.doInitH(component, event, helper);
    },
    cancelEdit: function (component, event, helper){
        helper.habilitarH(component, event, helper);
        helper.doInitH(component, event, helper);
    },
    handleClick : function (component, event, helper) {
        helper.habilitarH(component, event, helper);
    },
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");

        var values = event.getParam("value");
        var labels = component.get("v.listOptions")
              .filter(option => values.indexOf(option.value) > -1)
              .map(option => option.label);
      
        var selectedOptionlabel = event.getParam("label");
        console.log(selectedOptionValue);
        console.log(labels);
        console.log(values);
        // alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    },
    handleChangeInp : function (component, event, helper) {
        let fullrecord = component.get("v.fullrecord");
        var recId = fullrecord.Id;
        let JSON_OBJ = {};
        JSON_OBJ.Id = recId;

        let fields = component.get('v.registrolocal');
        fields.forEach(element => {
            for(var key in element) {
                JSON_OBJ[element[key].api_name] = element[key].value;
            }
        });
        // console.log('Hijo')
        // console.log(JSON_OBJ);
        var parentComponent = component.get("v.parent");                         
		parentComponent.childMethod(JSON_OBJ);
    },
})