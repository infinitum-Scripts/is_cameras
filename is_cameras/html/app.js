customcrs = L.extend({}, L.CRS.Simple, {
	projection: L.Projection.LonLat,
	scale: function(zoom) {
		return Math.pow(2, zoom);
	},
	zoom: function(sc) {
		return Math.log(sc) / 0.6931471805599453;
	},
	distance: function(pos1, pos2) {
		var x_difference = pos2.lng - pos1.lng;
		var y_difference = pos2.lat - pos1.lat;
		return Math.sqrt(x_difference * x_difference + y_difference * y_difference);
	},
	transformation: new L.Transformation(0.02072, 117.3, -0.0205, 172.8),
	infinite: false
});

var map = L.map("map", {
	crs: customcrs,
	minZoom: 3,
	maxZoom: 8,
	zoom: 4,
	noWrap: true,
	continuousWorld: false,
	preferCanvas: true,
	center: [0, -1024],
	maxBoundsViscosity: 1.0
});

var customImageUrl = './assets/map.jpg';
var sw = map.unproject([0, 1024], 3 - 1);
var ne = map.unproject([1024, 0], 3 - 1);
var mapbounds = new L.LatLngBounds(sw, ne);
map.setView([-400, -500], 4);
map.setMaxBounds(mapbounds);
map.attributionControl.setPrefix(false)
L.imageOverlay(customImageUrl, mapbounds).addTo(map);

map.on('dragend', function() {
	if (!mapbounds.contains(map.getCenter())) {
		map.panTo(mapbounds.getCenter(), { animate: false });
	}
});

var Cameras = {};
var CamerasPing = L.divIcon({
	html: '<i class="fa fa-location-dot fa-2x"></i>',
	iconSize: [20, 20],
	className: 'map-icon map-icon-ping',
	offset: [-10, 0]
});
var mapMarkers = L.layerGroup();

function CamerasMAP(CAMERA) {
	var COORDS_X = CAMERA.origin.x
	var COORDS_Y = CAMERA.origin.y
	var ID = CAMERA.id

	Cameras[ID] = L.marker([COORDS_Y, COORDS_X], { icon: CamerasPing });
	Cameras[ID].addTo(map);

	Cameras[ID].bindTooltip(`<div class="map-tooltip-info">${CAMERA.message}</div></div>`, {
		direction: 'top',
		permanent: false,
		offset: [0, -10],
		opacity: 1,
		interactive: true,
		className: 'map-tooltip'
	});

	Cameras[ID].addTo(mapMarkers);

	Cameras[ID].on('click', function() {
		const id = ID
		selectCam(id);
	});
}

function closePopup(){
	$('.popup').css('display', 'none');
}

function addCamera(){
	$('.popup').css('display', 'block');
}

window.addEventListener('message', (e) => {
	if(e.data.action == 'show'){
		$('.container').css('display', 'block');

		$(".leaflet-popup-pane").empty();
		$(".leaflet-marker-pane").empty();

		let display = 'none';

		if(e.data.manage == false){
			$('#add-button').css('display', 'none');
			display = 'none';
		}else{
			$('#add-button').css('display', 'block');
			display = 'block';
		}

		document.getElementById('cameras').innerHTML = '';
		for(let i=0;i<e.data.cameras.length;i++){
			document.getElementById('cameras').innerHTML += `
				<div class="camera">
					<span onclick="selectCam(${e.data.cameras[i].id})">${e.data.cameras[i].name}</span>
					<div class="remove-button" style="display: ${display}" onclick="removeCam(${e.data.cameras[i].id})">Usuń</div>
				</div>
			`;

			CamerasMAP({
				origin: {
					x: e.data.cameras[i].coords.x,
					y: e.data.cameras[i].coords.y
				},
				id: e.data.cameras[i].id,
				message: e.data.cameras[i].name
			})
		}

		document.getElementById('camType').innerHTML = '';
		for(let i=0;i<e.data.cameraTypes.length;i++){
			document.getElementById('camType').innerHTML += `
				<option value="${e.data.cameraTypes[i]}">${e.data.cameraTypes[i]}</option>
			`;
		}
	}

	if(e.data.action == 'loading'){
		$('.loading').animate({opacity: 1}, 500);
		setTimeout(() => {
			$('.loading').animate({opacity: 0}, 500);
		}, 3000);
	}
})

window.addEventListener('keydown', (e) => {
	if(e.key === "Escape"){
		close();
	}
})

function close(){
	$.post(`https://${GetParentResourceName()}/close`);
	$('.container').css('display', 'none');
	$('.popup').css('display', 'none');
}

function addCameraFunc(){
	let name = document.getElementById('camName').value;
	let type = document.getElementById('camType').value;

	close();
	$.post(`https://${GetParentResourceName()}/place`, JSON.stringify({model: type, name: name}))
}

function selectCam(id){
	close();
	$.post(`https://${GetParentResourceName()}/selectCam`, JSON.stringify({id: id}))
}

function removeCam(id){
	close();
	$.post(`https://${GetParentResourceName()}/removeCam`, JSON.stringify({id: id}));
}