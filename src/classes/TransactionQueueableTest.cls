/**
 * Created by Abu on 8/11/2022.
 */

@IsTest
public  class TransactionQueueableTest {

    @IsTest
    static void test(){

        //To Do Create Test factory

        Transaction__c testTransaction = new Transaction__c(
                Total_Discount__c = 100,
                Transaction_Date__c = System.today()
        );
        insert testTransaction;

        Transaction_Item__c[] items = new Transaction_Item__c[]{
                new Transaction_Item__c(Item_Cost__c = 1000, Transaction__c = testTransaction.Id),
                new Transaction_Item__c(Item_Cost__c = 2000, Transaction__c = testTransaction.Id)
        };
        insert items;

        Test.setMock(HttpCalloutMock.class, new TransactionCalloutTestMock());

        Test.startTest();

        //Enqueue Job
        Id jobId = System.enqueueJob(new TransactionQueueable(new Map<Id, Transaction_Item__c>(items)));

        Test.stopTest();

        //Assert here
        //To Do Add more meaningful asserts based on API response mock
        //To Do Test each call separately with its own mock class
        System.assert(jobId != null, 'Job failed');
    }


    public class TransactionCalloutTestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}