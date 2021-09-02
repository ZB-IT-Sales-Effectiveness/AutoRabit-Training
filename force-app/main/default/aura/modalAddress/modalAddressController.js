({
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        helper.getLocation(component, event, helper);
        component.set("v.isOpenAdd", true);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpenAdd", false);
    },

    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        alert('thanks for like Us :)');
        component.set("v.isOpenAdd", false);
    },
    initAdd: function(cmp, event, helper) {
        cmp.set("v.countryOptions", helper.getCountryOptions());
        cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
    },
    updateProvinces: function(cmp, event, helper) {
        if (cmp.get("v.previousCountry") !== cmp.get("v.country")) {
            cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
        }
        cmp.set("v.previousCountry", cmp.get("v.country"));
    },
    
 
})