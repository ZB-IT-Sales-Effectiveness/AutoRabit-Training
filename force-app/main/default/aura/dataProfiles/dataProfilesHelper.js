({
    doInitH : function (component,event,helper) {
        
        var localjson = [];
        let fullrecord = component.get("v.fullrecord")
        let fields = component.get("v.fields");

        fields.forEach(element => {
            let array = [];
            for(let item of element){
                let valor = fullrecord[item];
                let obj = {};

                let path = item.split('__')[0];
                let arr_name = path.split('/').pop().split(/(?=[A-Z])/);
                let _name = arr_name.join(' ');


                let listbox = true;
                let options = [];
                let defaultOptions = [];
                if(item == 'Specialties__c' || item == 'Procedures__c' || item == 'Devices__c'){
                    listbox = false;
                    if(valor != undefined && valor != null && valor != 'null'){
                        let arr = valor.split(';');

                        for(let item of arr){
                            let obj = { label: item, value: item };
                            options.push(obj);
                            defaultOptions.push(item)
                        }
                    }
                }
                
                if(valor != undefined && valor != null && valor != 'null'){
                    obj = {
                        api_name: item,
                        name: _name,
                        value: valor,
                        listbox: listbox,
                        listOptions: options,
                        defaultOptions: defaultOptions
                    }
                }else{
                    obj = {
                        api_name: item,
                        name: _name,
                        value: '',
                        listbox: listbox,
                        listOptions: options,
                        defaultOptions: defaultOptions
                    }
                }
                array.push(obj);
            }
            localjson.push(array);
        });
            
        component.set('v.registrolocal', localjson);
        // console.log(JSON.stringify(component.get('v.registrolocal')));
    },
    habilitarH : function(component, event, helper) {
        // helper.doInitH(component, event, helper);
        let val = component.get('v.disabledIn');
        component.set('v.disabledIn', !val);
    },
})