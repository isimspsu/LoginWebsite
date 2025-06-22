window.DefaultTiles = [{
    name: "Section1",
    tiles: [

        {
            id: "news1",
            name: "news"
        },

    ]
}];


// Convert it to a serialized string
window.DefaultTiles = _.map(window.DefaultTiles, function(section) {
    return "" + section.name + "~" + (_.map(section.tiles, function(tile) {
        return "" + tile.id + "," + tile.name;
    })).join(".");
}).join("|");

window.TileBuilders = {

    news: function(uniqueId) {
        return {
            uniqueId: uniqueId,
            name: "news",
            color: "bg-color-pink",
            size: "tile-double",
            appUrl: "http://www.bbc.co.uk/news/world/",
            scriptSrc: ["tiles/news/news.js?v=1"],
            cssSrc: ["tiles/news/news.css?v=1"],
            initFunc: "load_news",
            initParams: {
                url: "http://feeds.bbci.co.uk/news/world/rss.xml"
            }
        };
    },

















};