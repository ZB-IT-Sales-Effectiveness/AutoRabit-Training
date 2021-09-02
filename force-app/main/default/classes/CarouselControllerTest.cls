@isTest
private class CarouselControllerTest {
    
    @isTest static void getImageTest() {
	
		cloudx_cms__SS_Carousel__c c = new cloudx_cms__SS_Carousel__c();
		c.cloudx_cms__Name__c = 'Test Carousel';
		
		insert c;
        cloudx_cms__SS_Carousel__c d = [Select Id, Name, cloudx_cms__Name__c from cloudx_cms__SS_Carousel__c where Id = :c.Id];
        System.debug('Added Carousel is -> '+d.Name);
        System.debug('Added Carousel is -> '+c.Id);
		
		List<cloudx_cms__SS_Carousel_Slide__c> lstImages = new List<cloudx_cms__SS_Carousel_Slide__c>();
		for (integer i=0; i < 4; i++)
		{
			cloudx_cms__SS_Carousel_Slide__c cs = new cloudx_cms__SS_Carousel_Slide__c();
			
			cs.cloudx_cms__Title__c = 'This is the test slide '+i;
			if (i==0 || i == 2)
			cs.cloudx_cms__Image_URL__c = 'https://www.zimmerbiomet.com/content/dam/zimmer-biomet/image/Eric-Rubin.png';
			else 
			cs.cloudx_cms__Image_URL__c = 'https://www.zimmerbiomet.com/content/dam/zimmer-biomet/image/Steve-Weck.png';
            cs.cloudx_cms__Carousel__c = c.Id;
			
			lstImages.add(cs);
		}
		
		insert lstImages;
		
		List<cloudx_cms__SS_Carousel_Slide__c> carImages = CarouselController.getImageList(d.Name);
        System.debug('carImages -> '+carImages.size());
		System.assertEquals(carImages.size(), 4);
	}
}