var CC = CC || {};
CC.Map = CC.Map || {};

// build map with all of the pins clustered
var iconDir = '/assets/map_icons/';
var unclaimedStatusColorMap = {
  "Open, unassigned": "orange",
  "Open, assigned": "yellow",
  "Open, partially completed": "yellow",
  "Open, partially completed": "yellow",
  "Closed, completed": "green",
  "Closed, incomplete": "gray",
  "Closed, out of scope": "gray",
  "Closed, done by others": "gray",
  "Closed, no help wanted": "xgray",
  "Closed, rejected": "xgray",
  "Closed, duplicate": "xgray"
};

CC.Map.Marker = {};
