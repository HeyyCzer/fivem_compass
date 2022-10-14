const actions = {
	showUI,
	hideUI,

	setInformation,
	setCompassRotation,
}

function showUI() {
	$(".ui").fadeIn();
}

function hideUI() {
    $(".ui").fadeOut();
}

function setInformation({ zone, street }) {
	$(".zone").text(zone);
	$(".street").text(street);
}

const barElement = document.getElementsByTagName("svg")[1];
const headingElement = document.getElementsByTagName("svg")[0];
function setCompassRotation({ rotation }) {
	barElement.setAttribute("viewBox", "" + (rotation - 90) + " 0 180 5");
	headingElement.setAttribute("viewBox", "" + (rotation - 90 - 1) + " -5 180 1");
}

window.addEventListener("message", (event) => {
	const { data } = event;
	if (actions[data.action])
		actions[data.action](data);
});