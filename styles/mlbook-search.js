require([
    'gitbook',
    'jquery'
], function(gitbook, $) {
    function Search() {
        this.index = null;
        this.store = {};
        this.name = "MlBookLunrSearch";
    }

    Search.prototype.init = function() {
        var t = this;
        var d = $.Deferred();

        $.getJSON(gitbook.state.basePath + '/search.json').then(
            function (data) {
                console.log(data);
                t.index = lunr(function() {
                    this.ref('idx');
                    this.field('title');
                    this.field('url');
                    this.field('content');

                    var idx = this;
                    var i = 0;
                    data.forEach(function (doc) {
                        t.store[i] = doc;
                        idx.add({title: doc.title, content: doc.content, idx: i});
                        ++i;
                    });
                });
                d.resolve();
            }
        )

        return d.promise();
    }

    Search.prototype.search = function(q, offset, length) {
        var t = this;

        var results = $.map(t.index.search(q), function(result) {
            var doc = t.store[result.ref];

            return {
                title: doc.title,
                url: prefix + doc.url,
                body: doc.content
            };
        });
        console.log(results);

        return $.Deferred().resolve({
            query: q,
            results: results,
            count: results.length
        }).promise();
    }

    gitbook.events.bind('start', function(e, config) {
        var engine = gitbook.search.getEngine();
        if (!engine) {
            gitbook.search.setEngine(Search, config);
        }
    });
})