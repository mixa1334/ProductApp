public with sharing class ProductTableController {
    private static final Set<String> TYPES = allowedTypes();

    @AuraEnabled(cacheable=true)
    public static List<String> getProductTypes(){
        return new List<String>(TYPES);
    }

    @AuraEnabled
    public static List<ProductTable__c> getProducts(String searchName) {
        String query = 'SELECT Id, Name, Price__c, Amount__c, ProductType__c, ReleaseDate__c, Available__c ' +
                        'FROM ProductTable__c ';
        String orderBy = 'ORDER BY AddedDate__c DESC';
        if(String.isBlank(searchName)){
            query += orderBy;
            return (List<ProductTable__c>) Database.query(query);
        }
        searchName = '%' + searchName + '%';
        Map<String, Object> vars = new Map<String, Object>{'searchName' => searchName};
        query = query + 'WHERE Name LIKE :searchName '+ orderBy;
        return (List<ProductTable__c>) Database.queryWithBinds(query, vars, AccessLevel.USER_MODE);
    }

    @AuraEnabled
    public static ProductTable__c createProduct(ProductTable__c newProduct) {
        if (productIsInvalid(newProduct)) {
            throw new AuraHandledException('Invalid product data: ' + newProduct);
        }
        insert newProduct;
        return newProduct;
    }

    @AuraEnabled
    public static Boolean editProduct(ProductTable__c editedProduct){
        if (productIsInvalid(editedProduct)) {
            throw new AuraHandledException('Invalid product data: ' + editedProduct);
        }
        update editedProduct;
        return true;
    }

    @AuraEnabled
    public static Boolean deleteProduct(Id productId){
        List<ProductTable__c> productToDelete = [SELECT Id FROM ProductTable__c WHERE Id = :productId];
        if(productToDelete.isEmpty()){
            return false;
        }
        delete productToDelete;
        return true;
    }

    private static Set<String> allowedTypes() {
        Set<String> types = new Set<String>();
        for (Schema.PicklistEntry item : ProductTable__c.ProductType__c.getDescribe().getPicklistValues()) {
            if (item.isActive()) {
                types.add(item.getValue());
            }
        }
        return types;
    }

    private static Boolean productIsInvalid(ProductTable__c product){
        return product == null 
            || String.isBlank(product.Name)
            || product.Amount__c == null
            || product.Amount__c < 0
            || product.Price__c == null
            || product.Price__c <= 0
            || !TYPES.contains(product.ProductType__c)
            || product.ReleaseDate__c == null
            || product.ReleaseDate__c > Date.today();
    }
}