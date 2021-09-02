({
    helperMethod : function() {

    },
    countryProvinceMap: {
        US: [
            {'label': 'California', 'value': 'CA'},
            {'label': 'Texas', 'value': 'TX'},
            {'label': 'Washington', 'value': 'WA'}
        ],
        CN: [
            {'label': 'GuangDong', 'value': 'GD'},
            {'label': 'GuangXi', 'value': 'GX'},
            {'label': 'Sichuan', 'value': 'SC'}
        ],
        VA: []
    },
    countryOptions: [
        {'label': 'United States', 'value': 'US'},
        {'label': 'China', 'value': 'CN'},
        {'label': 'Vatican', 'value': 'VA'}
    ],
    getProvinceOptions: function(country) {
        return this.countryProvinceMap[country];
    },
    getCountryOptions: function() {
        return this.countryOptions;
    },
    getLocation: function (cmp, event, helper) {

        let address = cmp.get("v.address");
        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: address.Street__c,
                    City: address.City__c,
                    State: address.State__c
                },

                title: address.Name__c,
                description: address.Name__c
            }
        ]);
        cmp.set('v.zoomLevel', 16);
    }
})