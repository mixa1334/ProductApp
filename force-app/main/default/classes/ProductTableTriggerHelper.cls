public with sharing class ProductTableTriggerHelper {
    public static void processInsert(List<ProductTable__c> products) {
        for(ProductTable__c product : products){
            product.AddedDate__c = Datetime.now();
            checkAvailableField(product);
        }
    }

    public static void processUpdate(List<ProductTable__c> newProducts, Map<Id, ProductTable__c> oldProducts) {
        for(ProductTable__c product : newProducts){
            ProductTable__c oldProduct = oldProducts.get(product.Id);
            if(product.Amount__c != oldProduct.Amount__c || product.Available__c != oldProduct.Available__c){
                checkAvailableField(product);
            }
        }
    }

    private static void checkAvailableField(ProductTable__c product){
        product.Available__c = product.Amount__c != null && product.Amount__c > 0;
    }
}