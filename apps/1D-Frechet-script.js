const blueLine = document.getElementById('blue-line');
const redLine = document.getElementById('red-line');
const randomBlueButton = document.getElementById('random-blue');
const randomRedButton = document.getElementById('random-red');
const randomBlueCount = document.getElementById('random-blue-count');
const randomRedCount = document.getElementById('random-red-count');
const blueClearButton = document.getElementById('blue-clear');
const redClearButton = document.getElementById('red-clear');
const blueRemoveButton = document.getElementById('blue-remove-last');
const redRemoveButton = document.getElementById('red-remove-last');
const frechetDistance = document.getElementById('frechet-distance');
const distanceTable = document.getElementById('distance-table');
const redLineContainer = document.getElementById('red-line-container');
const markCellsContainer = document.getElementById('mark-cells-container');
const deltaInput = document.getElementById('delta-input');
const markCellsButton = document.getElementById('mark-cells-button');
const saveButton = document.getElementById('save-button');
const loadFile = document.getElementById('load-file');
const loadButton = document.getElementById('load-button');

let bluePoints = [];
let redPoints = [];

function addPoint(line, sequence, x) {
  const point = document.createElement('div');
  point.classList.add('point');
  point.style.left = `${x}px`;
  point.style.top = '50%';
  line.appendChild(point);
  sequence.push(x);
}

function removeLastPoint(line, sequence) {
//alert("removeLastPoint");
line.removeChild(line.lastChild);
  sequence.pop();
refresh();
}

function pickRandomPoints(line, sequence, count) {
  for (let i = 0; i < count; i++) {
    const x = Math.floor(Math.random() * 1000);
    addPoint(line, sequence, x);
  }
}

blueLine.addEventListener('click', (event) => {
//alert("addBluePoint");  
const x = event.offsetX;
  addPoint(blueLine, bluePoints, x);
  refresh();
});

randomBlueButton.addEventListener('click', () => {
  const count = parseInt(randomBlueCount.value);
  pickRandomPoints(blueLine, bluePoints, count);
});

blueClearButton.addEventListener('click', () => {
  // Clear existing points
      clearPoints(blueLine);
bluePoints = [];
refresh();
});

blueRemoveButton.addEventListener('click', () => {
//alert("blueRemove"); 
  // Clear existing points
       removeLastPoint(blueLine, bluePoints);
 refresh();
});

redLine.addEventListener('click', (event) => {
//alert("addRedPoint"); 
  const x = event.offsetX;
  addPoint(redLine, redPoints, x);
 refresh();
});

randomRedButton.addEventListener('click', () => {
  const count = parseInt(randomRedCount.value);
  pickRandomPoints(redLine, redPoints, count);
});

redClearButton.addEventListener('click', () => {
// Clear existing points
      clearPoints(redLine);
redPoints = [];
refresh();
});

redRemoveButton.addEventListener('click', () => {
//alert("redRemove"); 
  // Clear existing points
       removeLastPoint(redLine, redPoints);
 refresh();
});

function discreteFrechetDistance(P, Q) {
  const m = P.length;
  const n = Q.length;
  const ca = [];

  for (let i = 0; i < m; i++) {
    ca[i] = [];
    for (let j = 0; j < n; j++) {
      ca[i][j] = -1;
    }
  }

  function c(i, j) {
    if (ca[i][j] > -1) return ca[i][j];
    if (i === 0 && j === 0) {
      ca[i][j] = Math.abs(P[0] - Q[0]);
    } else if (i > 0 && j === 0) {
      ca[i][j] = Math.max(c(i - 1, 0), Math.abs(P[i] - Q[0]));
    } else if (i === 0 && j > 0) {
      ca[i][j] = Math.max(c(0, j - 1), Math.abs(P[0] - Q[j]));
    } else if (i > 0 && j > 0) {
      ca[i][j] = Math.max(
        Math.min(c(i - 1, j), c(i - 1, j - 1), c(i, j - 1)),
        Math.abs(P[i] - Q[j])
      );
    } else {
      ca[i][j] = Infinity;
    }
    return ca[i][j];
  }

  return c(m - 1, n - 1);
}

function createDistanceTable(P, Q, df) { // Now takes the df value as a parameter
  distanceTable.innerHTML = ''; // Clear table

  // Create header row
  const headerRow = distanceTable.insertRow();
  headerRow.insertCell(); // Empty cell for top-left corner
  for (let j = 0; j < Q.length; j++) {
    const headerCell = headerRow.insertCell();
    headerCell.textContent = Q[j]; //`B${j + 1}`;
headerCell.style.backgroundColor= 'lightgreen';
  }

  // Create data rows
  for (let i = 0; i < P.length; i++) {
    const row = distanceTable.insertRow();
    const labelCell = row.insertCell();
    labelCell.textContent = P[i]; //`R${i + 1}`;
labelCell.style.backgroundColor= 'lightgreen';
    for (let j = 0; j < Q.length; j++) {
      const cell = row.insertCell();
      const dist = Math.abs(P[i] - Q[j]);
      cell.textContent = dist;

      // Highlight cells with values <= Frechet distance
      if (dist <= df) {
        cell.style.backgroundColor = 'yellow'; // Or any style you prefer
      }
    }
  }
}


function markCellsByDelta(delta) {
  const tableRows = distanceTable.rows;

  for (let i = 1; i < tableRows.length; i++) { // Start from 1 to skip header row
    const cells = tableRows[i].cells;
    for (let j = 1; j < cells.length; j++) { // Start from 1 to skip label column
      const cellValue = parseFloat(cells[j].textContent);
      if (cellValue <= delta) {
        cells[j].style.backgroundColor = 'yellow'; // Highlight color for Delta
      } else {
        cells[j].style.backgroundColor = ''; // Reset background color if not <= delta
      }
    }
  }
}

markCellsButton.addEventListener('click', () => {
  const delta = parseFloat(deltaInput.value);
  markCellsByDelta(delta);
});


function clearPoints(line) {
    const points = line.querySelectorAll('.point');
    points.forEach(p => p.remove());
}

function saveData(data, filename) {
  const jsonData = JSON.stringify(data);
  const blob = new Blob([jsonData], { type: 'application/json' });
  const url = URL.createObjectURL(blob);

  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();

  URL.revokeObjectURL(url); // Clean up
}

function loadData(file) {
  const reader = new FileReader();

  reader.onload = (event) => {
    try {
      const data = JSON.parse(event.target.result);
      bluePoints = data.blue || [];
      redPoints = data.red || [];

      // Clear existing points
      clearPoints(blueLine);
      clearPoints(redLine);

      // Add loaded points to lines
      bluePoints.forEach(x => addPoint(blueLine, bluePoints, x));
      redPoints.forEach(x => addPoint(redLine, redPoints, x));

    } catch (error) {
      console.error('Error parsing JSON data:', error);
      alert('Invalid file format.');
    }
  };

  reader.onerror = (error) => {
    console.error('Error reading file:', error);
    alert('Error reading file.');
  };

  reader.readAsText(file);
}

saveButton.addEventListener('click', () => {
  const data = {
    blue: bluePoints,
    red: redPoints
  };
  saveData(data, 'sequences.json');
});

loadButton.addEventListener('click', () => {
  loadFile.click(); // Trigger the hidden file input
});

loadFile.addEventListener('change', (event) => {
  const file = event.target.files[0];
  if (file) {
    loadData(file);
  }
});

function refresh() {
   const df = discreteFrechetDistance(redPoints, bluePoints);
  frechetDistance.textContent = `Discrete Frechet Distance: ${df}`;
  createDistanceTable(redPoints, bluePoints, df); // Pass df to the function
}