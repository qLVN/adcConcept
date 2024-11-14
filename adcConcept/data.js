function sysout(text) {
	csl = document.getElementById('console');
	csl.innerHTML = csl.innerHTML + '\r\n' + text;
	csl.scrollTop = csl.scrollHeight;
	console.log('sysout: ' + text);
}

loadedEvents = {};
loadedMondays = []; //ex ['2024-11-26', etc]
currentMonday = '';

function loadAgendaData(dataString, mondayDate) {
	wrapper = document.getElementById('agenda-wrapper');
	if(wrapper.style.display = 'none') {
		wrapper.style.display = 'block';
		document.getElementById('navbar').style.display = 'block';
		document.getElementById('console').style.display = 'none';

		goToAgendaWeekForDay(mondayDate, true); //goes to the week of the mondayDate

		//add to loadedMondays
		loadedMondays.push(mondayDate);
		

		data = JSON.parse(dataString);

		data['hydra:member'].forEach(function(item) {
			addEvent(item);
		});
	}
}

function addEvent(item, firstTimeLoading) {
	//firstTimeLoading=true not supported
	if(firstTimeLoading == undefined) { firstTimeLoading = true; }

	itemStartDate = new Date(item['start']);
	itemEndDate = new Date(item['end']);

	//determining item day
	days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
	itemDay = days[itemStartDate.getDay()];

	if(itemDay != 'saturday' && itemDay != 'sunday' && item['identifier'].indexOf('AURION') != -1) {
		if(firstTimeLoading) {
			formattedDate = [itemStartDate.toISOString().slice(0, 10)];
			if(loadedEvents[formattedDate] == undefined) {
				loadedEvents[formattedDate] = {};
			}
			
			loadedEvents[formattedDate][Object.keys(loadedEvents[formattedDate]).length] = item;
		}

		topOffset = 5 + (itemStartDate.getHours() - 8)*30 + itemStartDate.getMinutes()/2;

		//calculating difference in time
		timeDiff = Math.abs(itemEndDate - itemStartDate);
		hoursDiff = Math.floor(timeDiff / (1000 * 60 * 60));
		minutesDiff = Math.floor((timeDiff % (1000 * 60 * 60)) / (1000 * 60));

		height = hoursDiff*30 + minutesDiff/2;
		
		if(Object.keys(item['places']).length !=0) {
			switch (item['places'][0]['site']) {
				case 'ATLANTIC CAMPUS':
					place = 'Atlantic';
					break;
				case 'CITY CAMPUS':
					place = 'City';
					break;
				default:
					place = 'Other';
					break;
			}
			room = item['places'][0]['code'];
			if(room == '35') { room = 'LL35'; } //Room 35 is called "Learning Lab"

			document.getElementById(itemDay).innerHTML += '<div onclick="toggleEvent(this);" eventName="' + item['name'] + '" style="height: ' + height + 'px; top: ' + topOffset + 'px;"><span class="title">' + item['name'] + '</span><span class="subtitle">' + place + ' - ' + room + '</span></div>';
		}
		else {
			document.getElementById(itemDay).innerHTML += '<div onclick="toggleEvent(this);" eventName="' + item['name'] + '" style="height: ' + height + 'px; top: ' + topOffset + 'px;"><span class="title">' + item['name'] + '</span></div>';
		}
	}
	
}

function previousWeek() {
	previousMonday = new Date(currentMonday);
	previousMonday.setDate(previousMonday.getDate() - 7);

	goToAgendaWeekForDay(previousMonday.toISOString().slice(0, 10), false);
}

function nextWeek() {
	nextMonday = new Date(currentMonday);
	nextMonday.setDate(nextMonday.getDate() + 7);

	goToAgendaWeekForDay(nextMonday.toISOString().slice(0, 10), false);
}

function goToAgendaWeekForDay(monday, willLoadData) {
	document.getElementById('info').style.display = 'none';

	currentMonday = monday;

	friday = new Date(monday);

	monthNames = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"];
	month = monthNames[friday.getMonth()];
	document.getElementById('month').innerText = month + ' ' + friday.getFullYear();

	friday.setDate(friday.getDate() + 5);
	document.getElementById('datespan').innerText = 'monday ' + monday.slice(8) + ' - friday ' + friday.toISOString().slice(8, 10);

	//clear each day-bar
	// document.querySelectorAll('.day-bar').forEach(function(bar) { //NOT SUPPORTED??
	// 	bar.innerHTML = '<span class="day-indicator">' + bar.id + '</span>';
	// });
	document.getElementById('monday').innerHTML = '<span class="day-indicator">monday</span>';
	document.getElementById('tuesday').innerHTML = '<span class="day-indicator">tuesday</span>';
	document.getElementById('wednesday').innerHTML = '<span class="day-indicator">wednesday</span>';
	document.getElementById('thursday').innerHTML = '<span class="day-indicator">thursday</span>';
	document.getElementById('friday').innerHTML = '<span class="day-indicator">friday</span>';

	if(!willLoadData) { //we have to request the new data if not present
		if(loadedMondays.indexOf(monday) != -1) { //already have the data (loadedMondays.includes(monday) seems to fail)
			initialDate = new Date(monday);

			for (i = 0; i <= 5; i++) {
				nextDate = new Date(initialDate);
				nextDate.setDate(initialDate.getDate() + i);
				data = loadedEvents[nextDate.toISOString().slice(0, 10)];
				if(data != undefined) {
					Object.keys(data).forEach(function(item) {
						addEvent(data[item], false);
					});
				}
			}
		} else {
			//Requesting data
			window.location = "tmrw://" + monday;
		}
	}
}

previousFocusedElement = undefined;

function toggleEvent(event) {
	infoText = document.getElementById('info');

	if(event.className != 'focused') {
		if(previousFocusedElement != undefined) {
			previousFocusedElement.className = '';
		}

		event.className = 'focused';
		previousFocusedElement = event;
		infoText.innerText = event.getAttribute('eventName');
		infoText.style.display = 'block';
	} else {
		event.className = '';
		previousFocusedElement = undefined;
		infoText.style.display = 'none';
	}
}

function toggleSettings() { //toggleSettings saves preferences once closed
	settingsPane = document.getElementById('settings-pane');
	settingsButton = document.getElementById('settings-button');
	titleText = document.getElementById('title');

	if(settingsPane.style.display == 'none') {
		settingsPane.style.display = 'block';
		settingsButton.innerText = 'Save';
		titleText.innerText = 'Settings';
	}
	else {
		settingsPane.style.display = 'none';
		settingsButton.innerText = 'Settings';
		titleText.innerText = 'Tomorrow';

		//SAVE SETTINGS HERE
	}
}