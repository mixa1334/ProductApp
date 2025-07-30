/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class TestProductTableApplication {

    @IsTest
    static void testGetProductTypes() {
        Test.startTest();
        List<String> types = ProductTableController.getProductTypes();
        Test.stopTest();
        
        Assert.areNotEqual(0, types.size());
    }

    @IsTest
    static void testGetProductsWithoutSearch() {
        insert new ProductTable__c(
            Name = 'Test Prod',
            Price__c = 10.0,
            Amount__c = 1,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        Test.startTest();
        List<ProductTable__c> result = ProductTableController.getProducts(null);
        Test.stopTest();

        Assert.areNotEqual(0, result.size());
    }

    @IsTest
    static void testGetProductsWithSearch() {
        insert new ProductTable__c(
            Name = 'Alpha',
            Price__c = 5.0,
            Amount__c = 2,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        Test.startTest();
        List<ProductTable__c> result = ProductTableController.getProducts('Alph');
        Test.stopTest();

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void testCreateProductSuccess() {
        ProductTable__c prod = new ProductTable__c(
            Name = 'Create Me',
            Price__c = 20.0,
            Amount__c = 3,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        Test.startTest();
        ProductTable__c created = ProductTableController.createProduct(prod);
        Test.stopTest();

        Assert.isNotNull(created.Id);
    }

    @IsTest
    static void testCreateProductFail() {
        ProductTable__c prod = new ProductTable__c(
            Name = '',
            Price__c = 0,
            Amount__c = -1,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today().addDays(1)
        );

        try {
            ProductTableController.createProduct(prod);
            Assert.fail();
        } catch (AuraHandledException ex) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void testEditProductSuccess() {
        ProductTable__c prod = new ProductTable__c(
            Name = 'Edit Me',
            Price__c = 15.0,
            Amount__c = 5,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        insert prod;
        prod.Price__c = 30.0;

        Test.startTest();
        Boolean success = ProductTableController.editProduct(prod);
        Test.stopTest();

        Assert.isTrue(success);
    }

    @IsTest
    static void testDeleteProductSuccess() {
        ProductTable__c prod = new ProductTable__c(
            Name = 'Delete Me',
            Price__c = 10.0,
            Amount__c = 1,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        insert prod;

        Test.startTest();
        Boolean deleted = ProductTableController.deleteProduct(prod.Id);
        Test.stopTest();

        Assert.isTrue(deleted);
    }

    @IsTest
    static void testDeleteProductFail() {
        Test.startTest();
        Boolean deleted = ProductTableController.deleteProduct('001000000000000AAA');
        Test.stopTest();

        Assert.isFalse(deleted);
    }


    @IsTest
    static void testProcessInsertSetsAddedDateAndAvailability() {
        ProductTable__c prod = new ProductTable__c(
            Name = 'Inserted Prod',
            Price__c = 99.0,
            Amount__c = 5,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today()
        );

        List<ProductTable__c> products = new List<ProductTable__c>{ prod };

        Test.startTest();
        ProductTableTriggerHelper.processInsert(products);
        Test.stopTest();

        System.Assert.isNotNull(products[0].AddedDate__c, 'AddedDate__c должна быть установлена');
        System.Assert.isTrue(products[0].Available__c, 'Available__c должна быть true, т.к. Amount__c > 0');
    }

    @IsTest
    static void testProcessInsertUnavailableWhenAmountIsZero() {
        ProductTable__c prod = new ProductTable__c(
            Name = 'Zero Amount',
            Price__c = 12.0,
            Amount__c = 0,
            ProductType__c = 'Home',
            ReleaseDate__c = Date.today()
        );

        List<ProductTable__c> products = new List<ProductTable__c>{ prod };

        Test.startTest();
        ProductTableTriggerHelper.processInsert(products);
        Test.stopTest();

        System.Assert.isFalse(products[0].Available__c, 'Available__c должна быть false при Amount__c = 0');
    }
}


