/**
 * ARK Performance-Modul · Shared Sample-Data
 * Single-Source-of-Truth fuer Demo-Daten ueber alle Performance-Mockups.
 *
 * Verwendung im Mockup:
 *   <script src="../../_shared/perf-sample-data.js"></script>
 *   const cantons = window.ARK_PERF.kantone;
 *
 * Backend-Connect-Migration:
 *   tausche window.ARK_PERF.* gegen GET /api/v1/performance/*
 *   - Daten-Shape kompatibel (gleiche Keys, gleiche Typen)
 *   - jede Top-Level-Section ist 1:1 ein Endpoint-Response
 *
 * Stand: 2026-04-25 (Q2 2026 Demo-Schnitt)
 *
 * Stammdaten-konform (raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md):
 *   - Sparten: ARC, GT, ING, PUR, REM (§8)
 *   - Stages: Expose, CV Sent, TI, 1st, 2nd, 3rd, Assessment, Offer, Placement (§13)
 *   - MA-Kuerzel: 2-Buchstaben (PW, JV, LR, ST, MR)
 *   - Kantone: 26 CH-Kantone (ISO 3166-2:CH)
 */

window.ARK_PERF = {

  // ---- Meta ---------------------------------------------------------------
  meta: {
    today: '2026-04-25',
    periode: 'Q2 2026',
    currency: 'CHF',
    months_short: ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'],
    weekdays_short: ['Mo','Di','Mi','Do','Fr','Sa','So'],
  },

  // ---- Sparten (5 Stammdaten-konform) ------------------------------------
  // revenue_ytd / pipeline / forecast in CHF.  conversion in % (Process→Placement).
  // coverage in % (kontaktierte Kandidaten / Marktpotenzial).
  // dashboard_quarter = Mini-Bar-Wert fuer Dashboard-Sparten-Card (CHF k aktuelles Quartal).
  sparten: [
    { code:'ARC', name:'Architektur',          revenue_ytd:720000, conversion:5.1, coverage:78, mandate:12, pipeline:980000, forecast:1200000, color:'#1A3A5C', dashboard_quarter:142 },
    { code:'ING', name:'Ingenieurwesen',       revenue_ytd:510000, conversion:2.9, coverage:71, mandate: 9, pipeline:640000, forecast: 820000, color:'#4D7299', dashboard_quarter:118 },
    { code:'GT',  name:'Gartenbau/Tiefbau',    revenue_ytd:140000, conversion:3.8, coverage:68, mandate: 4, pipeline:150000, forecast: 200000, color:'#9B7B5C', dashboard_quarter: 86 },
    { code:'PUR', name:'Industrie/Purchasing', revenue_ytd:290000, conversion:1.8, coverage:52, mandate: 7, pipeline:360000, forecast: 480000, color:'#B8860B', dashboard_quarter: 64 },
    { code:'REM', name:'Real-Estate-Management',revenue_ytd:180000, conversion:4.2, coverage:79, mandate: 6, pipeline:280000, forecast: 360000, color:'#6B9B7A', dashboard_quarter: 42 },
  ],

  // Sparten-Conversion ueber 4 Quartale (Q1..Q4 2026) — fuer business.html Line-Chart.
  // Werte in % (Process→Placement).
  sparten_conversion_quarters: {
    quarters: ['Q1','Q2','Q3','Q4'],
    median: 3.3,
    series: {
      ARC: [4.8, 5.1, 5.3, 5.2],
      ING: [2.7, 2.9, 3.0, 3.1],
      PUR: [2.4, 1.8, 1.9, 2.0],
      REM: [3.6, 4.2, 4.4, 4.5],
      GT:  [3.5, 3.8, 3.6, 4.1],
    },
  },

  // Sparten-Trend rolling 12 months (CHF k revenue) — fuer dashboard.html Trend-Chart.
  sparten_trend_12m: {
    months: ['Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez','Jan','Feb','Mär','Apr'],
    series: {
      ARC: [42, 48, 55, 52, 60, 58, 64, 70, 68, 72, 78, 82],
      GT:  [28, 30, 26, 32, 36, 38, 35, 40, 44, 42, 46, 50],
      ING: [55, 60, 64, 70, 66, 72, 68, 64, 70, 76, 80, 78],
      PUR: [34, 38, 36, 40, 42, 38, 36, 32, 30, 34, 36, 40],
      REM: [22, 24, 28, 26, 30, 32, 30, 34, 36, 32, 34, 30],
    },
  },

  // ---- Mitarbeiter (Stammdaten-konform: 2-Buchstaben-Kuerzel) ------------
  // pipeline_wert / forecast in CHF; goal_pct/compliance in %.
  // Vollstaendige ARK-MA-Matrix 2026 in memory/project_arkadium_roles_2026.md.
  mitarbeiter: [
    { code:'PW', rolle:'Senior Partner · AM', pipeline_wert:480000, goal_pct:75, goal_done:3, goal_total:4, compliance:100, aktivitaet:47, anomalien:2, forecast:620000 },
    { code:'JV', rolle:'Manager · CM',         pipeline_wert:320000, goal_pct:62, goal_done:2, goal_total:4, compliance:100, aktivitaet:41, anomalien:1, forecast:410000 },
    { code:'LR', rolle:'Researcher',           pipeline_wert:180000, goal_pct:45, goal_done:1, goal_total:3, compliance: 75, aktivitaet:32, anomalien:2, forecast:250000 },
    { code:'ST', rolle:'Senior Consultant',    pipeline_wert:240000, goal_pct:80, goal_done:3, goal_total:4, compliance:100, aktivitaet:38, anomalien:0, forecast:320000 },
    { code:'MR', rolle:'Junior Consultant',    pipeline_wert:240000, goal_pct:80, goal_done:3, goal_total:4, compliance:100, aktivitaet:38, anomalien:0, forecast:320000 },
  ],

  // Heatmap-Daten 12 MA × 7 Wochentage (Aktivitaets-Touches pro Tag) — dashboard.html.
  // Synthetische Pseudo-Stable-Series; Function val(r,c) deterministisch.
  mitarbeiter_heatmap_full: {
    members: [
      'Peter W.', 'Sabine N.', 'Marius B.', 'Lara R.',
      'Daniel H.', 'Julia K.', 'Felix A.', 'Anna S.',
      'Rico M.', 'Tina B.', 'Jonas E.', 'Eva L.',
    ],
    days: ['Mo','Di','Mi','Do','Fr','Sa','So'],
    // Generator-Funktion (kompatibel mit aktueller dashboard.html-Logik) liefert val(r,c).
    val: function(r, c) {
      const seed = (r * 17 + c * 31 + 7) % 100;
      if (c >= 5) return Math.max(0, Math.round(seed / 30) - 1);
      const midBias = c === 2 ? 1.4 : c === 1 || c === 3 ? 1.2 : 1.0;
      return Math.max(1, Math.round((seed % 22) * midBias / 1.1));
    },
  },

  // 5-Wochen × 7-Tage Heatmap fuer einzelnen MA (mitarbeiter.html „Mein Profil").
  mitarbeiter_heatmap_5wk: {
    weeks: ['KW14','KW15','KW16','KW17','KW18'],
    days: ['Mo','Di','Mi','Do','Fr','Sa','So'],
    data: [
      [ 8, 11,  9,  7,  6, 1, 0],
      [10, 12,  8, 11,  9, 2, 0],
      [ 7,  9, 12, 14, 10, 1, 1],
      [11, 13, 10,  9,  8, 0, 0],
      [ 9, 12, 11, 10,  7, 2, 0],
    ],
  },

  // 12-Wochen × 5-Activity-Type Stacked-Bar (mitarbeiter.html Aktivitaets-Tab).
  // Activity-Types Stammdaten-konform: Kontaktberuehrung, Emailverkehr, Coaching, Briefing, Debriefing.
  activity_weeks: {
    weeks: [
      { kw: 7,  values: [12, 18, 4, 2, 1] },
      { kw: 8,  values: [15, 16, 5, 3, 2] },
      { kw: 9,  values: [11, 19, 6, 4, 1] },
      { kw:10,  values: [14, 14, 4, 2, 2] },
      { kw:11,  values: [16, 17, 7, 3, 3] },
      { kw:12,  values: [13, 15, 5, 4, 2] },
      { kw:13,  values: [10, 12, 4, 2, 1] },
      { kw:14,  values: [15, 18, 6, 3, 2] },
      { kw:15,  values: [17, 19, 8, 4, 3] },
      { kw:16,  values: [16, 17, 7, 3, 2] },
      { kw:17,  values: [14, 16, 6, 3, 2] },
      { kw:18,  values: [15, 17, 9, 4, 2] },
    ],
    types: [
      { name:'Kontaktberührung', color:'var(--accent)', total:168 },
      { name:'Emailverkehr',     color:'#5588B3',       total:198 },
      { name:'Coaching',         color:'var(--gold)',   total: 71 },
      { name:'Briefing',         color:'var(--green)',  total: 37 },
      { name:'Debriefing',       color:'var(--amber)',  total: 23 },
    ],
    median: 41,
    total_label: '497 Touches',
  },

  // ---- Funnel · 9 Stammdaten-Stages (§13 dim_process_stages) -------------
  // count = absolute Anzahl Prozesse aktuell in diesem Stage.
  // conv = Conversion-Prozent zum naechsten Stage; days = avg Verweildauer; drop = Drop-Off absolut.
  // danger = visuelle Warnung (TI = bekanntes Bottleneck).
  stages: [
    { code:'Expose',     count:240, conv: 38,  days:  4, drop:149 },
    { code:'CV Sent',    count: 91, conv: 49,  days:  6, drop: 46 },
    { code:'TI',         count: 45, conv: 29,  days:  9, drop: 32, danger:true },
    { code:'1st',        count: 13, conv: 62,  days:  7, drop:  5 },
    { code:'2nd',        count:  8, conv: 75,  days:  8, drop:  2 },
    { code:'3rd',        count:  6, conv: 83,  days:  6, drop:  1 },
    { code:'Assessment', count:  5, conv: 80,  days: 12, drop:  1 },
    { code:'Offer',      count:  4, conv:100,  days:  3, drop:  0 },
    { code:'Placement',  count:  4, conv:null, days:null, drop:null },
  ],

  // Cohort-Heatmap base curve (rough conversion-rate at each stage from Expose=100).
  // funnel.html Cohort-Tab Pseudo-Generator.
  stages_cohort: {
    months: ['Mai 25','Jun 25','Jul 25','Aug 25','Sep 25','Okt 25','Nov 25','Dez 25','Jan 26','Feb 26','Mär 26','Apr 26'],
    base_curve: [100, 38, 18.6, 5.4, 3.4, 2.8, 2.2, 1.8, 1.6],
  },

  // ---- Kantone (26 CH Stammdaten, ISO 3166-2:CH) -------------------------
  // score = Coverage % (kontaktiert / total Marktpotenzial).
  // contacted/total = Kandidaten-Counts.
  kantone: [
    { code:'ZH', name:'Zürich',                 score:92, contacted:51, total:55 },
    { code:'BE', name:'Bern',                   score:74, contacted:28, total:38 },
    { code:'LU', name:'Luzern',                 score:68, contacted:13, total:19 },
    { code:'UR', name:'Uri',                    score:35, contacted: 2, total: 6 },
    { code:'SZ', name:'Schwyz',                 score:52, contacted: 6, total:12 },
    { code:'OW', name:'Obwalden',               score:41, contacted: 3, total: 7 },
    { code:'NW', name:'Nidwalden',              score:48, contacted: 4, total: 8 },
    { code:'GL', name:'Glarus',                 score:38, contacted: 3, total: 8 },
    { code:'ZG', name:'Zug',                    score:88, contacted:14, total:16 },
    { code:'FR', name:'Freiburg',               score:62, contacted:11, total:18 },
    { code:'SO', name:'Solothurn',              score:71, contacted:12, total:17 },
    { code:'BS', name:'Basel-Stadt',            score:84, contacted:21, total:25 },
    { code:'BL', name:'Basel-Landschaft',       score:78, contacted:18, total:23 },
    { code:'SH', name:'Schaffhausen',           score:65, contacted: 8, total:13 },
    { code:'AR', name:'Appenzell Ausserrhoden', score:43, contacted: 3, total: 7 },
    { code:'AI', name:'Appenzell Innerrhoden',  score:25, contacted: 1, total: 4 },
    { code:'SG', name:'St. Gallen',             score:69, contacted:18, total:26 },
    { code:'GR', name:'Graubünden',             score:34, contacted: 7, total:21 },
    { code:'AG', name:'Aargau',                 score:81, contacted:24, total:30 },
    { code:'TG', name:'Thurgau',                score:67, contacted:11, total:16 },
    { code:'TI', name:'Tessin',                 score:43, contacted: 6, total:14 },
    { code:'VD', name:'Waadt',                  score:76, contacted:32, total:42 },
    { code:'VS', name:'Wallis',                 score:48, contacted: 9, total:19 },
    { code:'NE', name:'Neuenburg',              score:58, contacted: 8, total:14 },
    { code:'GE', name:'Genf',                   score:82, contacted:24, total:29 },
    { code:'JU', name:'Jura',                   score:31, contacted: 3, total:10 },
  ],

  // BFS-Kantonsnummer (TopoJSON id) → ISO 3166-2:CH 2-Buchstaben-Code.
  kanton_id_to_code: {
     1:'ZH',  2:'BE',  3:'LU',  4:'UR',  5:'SZ',  6:'OW',  7:'NW',  8:'GL',
     9:'ZG', 10:'FR', 11:'SO', 12:'BS', 13:'BL', 14:'SH', 15:'AR', 16:'AI',
    17:'SG', 18:'GR', 19:'AG', 20:'TG', 21:'TI', 22:'VD', 23:'VS', 24:'NE',
    25:'GE', 26:'JU',
  },

  // Kritische Kandidatenliste (coverage.html „Critical-List"-Drawer).
  // Sparte/Owner Stammdaten-konform.  last/soll = Tage seit letztem Kontakt / Soll-Pflege-Zyklus.
  critical_candidates: [
    { id:'FA', avatar:'green', sparte:'ARC', owner:'LR', last:31, soll:14, score:22, checked:false, canton:'AI' },
    { id:'RM', avatar:'gold',  sparte:'ARC', owner:'PW', last:26, soll:14, score:32, checked:true,  canton:'ZH' },
    { id:'BL', avatar:'red',   sparte:'PUR', owner:'LR', last:24, soll:14, score:38, checked:true,  canton:'JU' },
    { id:'TM', avatar:'amber', sparte:'ING', owner:'JV', last:22, soll:14, score:41, checked:false, canton:'GR' },
    { id:'SK', avatar:'',      sparte:'ARC', owner:'PW', last:21, soll:14, score:45, checked:true,  canton:'ZH' },
    { id:'KH', avatar:'',      sparte:'PUR', owner:'MR', last:19, soll:21, score:52, checked:false, canton:'TI' },
    { id:'NW', avatar:'',      sparte:'GT',  owner:'ST', last:18, soll:21, score:58, checked:false, canton:'UR' },
    { id:'DR', avatar:'',      sparte:'REM', owner:'JV', last:17, soll:14, score:62, checked:false, canton:'GE' },
    { id:'EL', avatar:'',      sparte:'ING', owner:'LR', last:15, soll:14, score:64, checked:false, canton:'AR' },
    { id:'MO', avatar:'',      sparte:'ARC', owner:'MR', last:14, soll:14, score:68, checked:false, canton:'VS' },
  ],

  // ---- Revenue (revenue.html Hauptdiagramm) ------------------------------
  // Ist 2026 Jan..Mar full + Apr partial; Forecast: Apr-Rest + Mai..Dez; Vorjahr 2025 vergleichend.
  // Werte in CHF k.
  revenue_chart: {
    months: ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'],
    ist:      [320, 280, 410, 250, null, null, null, null, null, null, null, null],
    forecast: [null, null, null,  90,  290,  310,  280,  250,  270,  320,  340,  360],
    vorjahr:  [240, 260, 290, 270,  250,  280,  260,  230,  270,  300,  320,  310],
    ymax: 400,
    ygrid: [0, 100, 200, 300, 400],
    today_marker: 'Apr',  // Heute-Separator zwischen Ist und Forecast
  },

  // Donut-Diagramm Sparten-Anteil (business.html Drawer).
  sparten_donut: [
    { code:'ARC', value:60 },
    { code:'ING', value:28 },
    { code:'REM', value:12 },
  ],

  // ---- Goal-Verteilung Presets (team.html Bulk-Drawer) -------------------
  goal_distribution_presets: {
    gleich:        { PW:'4 Placements', JV:'4 Placements', LR:'4 Placements', MR:'4 Placements' },
    proportional:  { PW:'6 Placements', JV:'4 Placements', LR:'2 Placements', MR:'3 Placements' },
    manuell:       { PW:'— manuell —',  JV:'— manuell —',  LR:'— manuell —',  MR:'— manuell —' },
  },

};
