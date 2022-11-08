# test-dev-org


Assumptions:
- Calls to be made After Insert assuming we have all the entries for transaction items we need
- API only supports one group of Transactions Items linked to a single Transaction Record per call

To Do's / Impprovemnets:
- Implement a trigger framework
- Add hanlding for the Callout Response
- Create Test Factory Class
- Add more meaming full asserts 
- Test each callout separately
- Bulkify callout: Add Callout stack check to see not more than 100 callouts are processed in a single job if there are more requeue the job with remaing items.
