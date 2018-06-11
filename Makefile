.PHONY : clean setup run-tests

couchdb := http://till:till@127.0.0.1:5984
db := test-database
endpoint := $(couchdb)/$(db)
dir := $(shell pwd)
curl_post := @curl -X POST -H "Content-Type: application/json"
curl_put := @curl -X PUT -H "Content-Type: application/json"

clean:
	@echo "Deleting $(db)"
	curl -X DELETE $(endpoint)

setup:
	@echo "Creating database(s)"
	$(curl_put) $(couchdb)/_users
	$(curl_put) $(endpoint)
	@echo "Populating '$(db)' with test data/fixtures"
	$(curl_post) -d @$(dir)/test/doc1.json $(endpoint)
	$(curl_post) -d @$(dir)/test/doc2.json $(endpoint)
	$(curl_post) -d @$(dir)/test/doc3.json $(endpoint)
	$(curl_post) -d @$(dir)/test/doc4.json $(endpoint)
	@echo "Creating index (Mango)"
	$(curl_post) -d '{"_id":"_design/mango-index"}' $(endpoint)
	$(curl_post) -d @$(dir)/test/test-index1.txt $(endpoint)/_index

run-tests:
	@echo "Query 1"
	$(curl_post) -d @$(dir)/test/test-query1.txt $(endpoint)/_find
	@echo "Query 2"
	$(curl_post) -d @$(dir)/test/test-query2.txt $(endpoint)/_find

test: clean setup run-tests