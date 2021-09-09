public with sharing class CarouselController {
    public CarouselController() {

    }

    @AuraEnabled
	public static List<cloudx_cms__SS_Carousel_Slide__c> getImageList(String carousel) {
        //List<cloudx_cms__SS_Carousel_Slide__c> lstFiles = new List<cloudx_cms__SS_Carousel_Slide__c>();
        System.debug('Fetching Images for Carousel : '+carousel);
        List<cloudx_cms__SS_Carousel_Slide__c> lstFiles = [SELECT Id,cloudx_cms__Carousel__c,cloudx_cms__Image_URL__c, cloudx_cms__Title__c, cloudx_cms__Title_Text_Size__c, cloudx_cms__Slide_Order__c,imgLink__c FROM cloudx_cms__SS_Carousel_Slide__c where cloudx_cms__Carousel__r.Name = :carousel and RecordType.Name = 'Image' order by cloudx_cms__Slide_Order__c];
	if (lstFiles != null && lstFiles.size() > 0)
		System.debug('Carousel has :'+lstFiles.size() + ' images');
        return lstFiles;
    }
}
