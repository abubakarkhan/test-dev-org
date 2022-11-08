/**
 * Created by Abu on 8/11/2022.
 */

public with sharing class TransactionQueueable implements Queueable, Database.AllowsCallouts {

    //Placeholder endpoints
    private static final String TRANSACTION_ITEM_ENDPOINT = 'test_transaction_item';
    private static final String TRANSACTION_ENDPOINT = 'test_transaction';

    //Transaction Item map from the trigger
    private final Map<Id, Transaction_Item__c> mapTransactionItems;

    //Queried transaction data
    private Map<Id, Transaction__c> mapTransactionsByIds = new Map<Id, Transaction__c>();

    public TransactionQueueable(Map<Id, Transaction_Item__c> mapTransactionItems) {
        this.mapTransactionItems = mapTransactionItems;
    }

    public void execute(QueueableContext param1) {
        queryData();
        sendData();
    }

    private void queryData() {
        //Get id's of all the transaction record
        for (Transaction_Item__c item : this.mapTransactionItems.values()) {
            mapTransactionsByIds.put(item.Transaction__c, null);
        }

        //Query all transaction items for each transaction record
        mapTransactionsByIds = new Map<Id, Transaction__c>([
                SELECT Id,
                        Total_Cost__c,
                        Total_Discount__c,
                        Transaction_Date__c, (
                        SELECT Id,
                                Item_Cost__c,
                                Name
                        FROM Transaction_Items__r
                )
                FROM Transaction__c
        ]);
    }

    private void sendData() {
        for (Transaction__c transactionRecord : mapTransactionsByIds.values()) {
            //have transaction items
            Transaction_Item__c[] items = transactionRecord.Transaction_Items__r;
            if (!items.isEmpty()) {
                //Rest Call 1 Response
                HttpResponse response = sendRequest(TRANSACTION_ITEM_ENDPOINT, 'POST', createTransactionItemsBody(items));

                //Rest Call 1 is successful
                //Assuming 200 is success
                if(response.getStatusCode() == 200){
                    //Rest Call 2 Response
                    HttpResponse responseTransaction = sendRequest(TRANSACTION_ENDPOINT, 'POST', createTransactionBody(transactionRecord));
                    //To Do handle response
                }
            }
        }
    }

    private static HttpResponse sendRequest(String endpoint, String method, String bodyString) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint); //Endpoint can also use named credentials or pass
        req.setMethod(method); // POST,GET,PUT etc.
        req.setHeader('Authorization', 'Bearer ' + (Test.isRunningTest() ? 'TestToken' : getAccessToken())); //If the rest api requires a token
        req.setHeader('Content-Type', 'application/json');
        if (String.isNotBlank(bodyString)) {
            req.setBody(bodyString);
        }
        Http http = new Http();
        return http.send(req);
    }

    private static String getAccessToken() {
        //To Do Get token from api
        return 'sample_access_token';
    }

    /**
     * @param transactionItems Transaction_Item__c record list
     *
     * @return transactionItems list converted to JSON string for Rest API Call 1
     */
    private static String createTransactionItemsBody(Transaction_Item__c[] transactionItems) {
        JSONGenerator gen = JSON.createGenerator(true);

        //Start json array for transaction items
        gen.writeStartArray();

        for(Transaction_Item__c item: transactionItems){
            //Transaction item start
            gen.writeStartObject();

            //Start Key object
            gen.writeFieldName('keys');
            gen.writeStartObject();
            gen.writeStringField('TransactionItemID', item.Id);
            //End Key object
            gen.writeEndObject();

            //Start Values object
            gen.writeFieldName('values');
            //Sample api accepts data in string format
            gen.writeStartObject();
            gen.writeStringField('ItemCost', toString(item.Item_Cost__c));
            gen.writeStringField('ItemName', item.Name);
            //End Values object
            gen.writeEndObject();

            //Transaction item end
            gen.writeEndObject();

        }

        //End json array for transaction items
        gen.writeEndArray();

        return gen.getAsString();
    }

    /**
     * @param transactionRecord Transaction__c record
     *
     * @return Transaction__c record converted to JSON string for Rest API Call 2
     */
    public static String createTransactionBody(Transaction__c transactionRecord) {
        JSONGenerator gen = JSON.createGenerator(true);

        //Transaction Record Object Start
        gen.writeStartObject();

        //Start Key object
        gen.writeFieldName('keys');
        gen.writeStartObject();
        gen.writeStringField('TransactionID', transactionRecord.Id);
        //End Key object
        gen.writeEndObject();

        //Start Values object
        gen.writeFieldName('values');
        //Sample api accepts data in string format
        gen.writeStartObject();
        gen.writeStringField('TotalCost', toString(transactionRecord.Total_Cost__c));
        gen.writeStringField('TotalDiscount', toString(transactionRecord.Total_Discount__c));
        gen.writeStringField('TransactionDate', toString(transactionRecord.Transaction_Date__c));
        //End Values object
        gen.writeEndObject();

        //Transaction Record Object end
        gen.writeEndObject();

        return gen.getAsString();
    }

    private static String toString(Object obj){
        //Convert date to format accepted by the API
        if(obj instanceof Date){
            return ((Datetime)obj).format('YYYY-MM-dd');
        }
        return String.valueOf(obj);
    }
}