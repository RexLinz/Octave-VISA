% Agilent 33250A / MSO-X 2024 bode plotter

global visaRM
global visaMSO
global visaFG
global useScopeFG

if visaFG>0
  viClose(visaFG);
end
if visaMSO>0
  viClose(visaMSO);
end
if visaRM>0
  viClose(visaRM);
end

visaRM  = int32(0); % VISA handle to resource manager
visaMSO = int32(0); % VISA handle to scope
visaFG  = int32(0); % VISA handle to function generator
useScopeFG = 1;

% set up GUI layout
uiFig = figure(1,
  "name", "bode plotter",
  "toolbar", "none",
  "menubar", "none",
  "position", [24 206 790 470]
);
clf;

% open and initialize oscilloscope with default
function MSO = initMSO(source, event)
  global visaRM;
  if visaRM==0
    visaRM = viOpenDefaultRM();
  end
  global visaMSO;
  disp("initialize scope");
  if visaMSO==0
    [visaMSO, status] = viOpen(visaRM, "MSO-USB", 5000, 10);
  end
  if visaMSO>0
    % get input and output channels
    global configTable;
    config = get(configTable, "data"); % vector of numbers in column 2
    labels = {"IN", "OUT"};
    for c = 1:2 % line indices to table
      channelNumber = cell2mat(config(c+8,2));
      chString = [":CHAN" num2str(channelNumber)];
      viWrite(visaMSO, [chString ":DISP ON\n"]);     % enable channel
      viWrite(visaMSO, [chString ":BWLimit ON\n"]);  % 20 MHz bandwidth
      viWrite(visaMSO, [chString ":COUPling AC\n"]); % AC coupling
      viWrite(visaMSO, [chString ":RANGE 8.0\n"]);   % full scale range
      viWrite(visaMSO, [chString ":OFFset 0.0\n"]);  % no offset
      viWrite(visaMSO, [chString ":UNIT VOLT\n"]);   % voltage displayed
      viWrite(visaMSO, [chString ":LAB \"" char(labels(c)) "\"\n"]);
    end
    viWrite(visaMSO, ":DISPlay:LABel ON\n");

    viWrite(visaMSO, ":TRIG:MODE EDGE\n");         % trigger on edge
    viWrite(visaMSO, ":TRIG:EDGE:SLOP POS\n");     % positive edge
    channelNumber = cell2mat(config(9,2));         % input to DUT
    chString = ["CHAN" num2str(channelNumber)];
    viWrite(visaMSO, [":TRIG:EDGE:LEVel 0\n"]);    % trigger on channelIn
    viWrite(visaMSO, [":TRIG:EDGE:SOURCE " chString "\n"]);  % trigger on channelIn
    % TODO: might add trigger coupling AC, noise reject and HF reject?

    % NOTE: averaging significantly slowing down on low frequency
    switch 2
      case 1 % averaging
        viWrite(visaMSO, ":ACQuire:TYPE AVERage\n");
        viWrite(visaMSO, ":ACQuire:COUNt 8\n");
      case 2 % hires
        viWrite(visaMSO, ":ACQuire:TYPE HRES\n");
      otherwise % normal
        viWrite(visaMSO, ":ACQuire:TYPE NORM\n");
    end

    viWrite(visaMSO, ":TIM:REFerence CENTer\n"); % trigger point in center
    viWrite(visaMSO, ":TIM:RANGE 0.005\n");      % 5 periods of 1 kHz
  else
    disp("  no connection to scope");
  end
end
uimenu("text", "init &MSO", "accelerator", "m", "menuselectedfcn", @initMSO);

% open and initialze 33250A function generator with defaults
function initFG(source, event)
  global visaRM
  if visaRM==0
    visaRM = viOpenDefaultRM();
  end
  global visaFG
  disp("initialize function generator");
  if visaFG==0 % device not opened so far
%    FG = viOpen(visaRM, "USB0::0x03EB::0x2065::Agilent_Technologies_33250A_0_1.03-1.01-1.00-03-1::INSTR");
    [visaFG, status] = viOpen(visaRM, "33250A", 3000, 10);
  end
  if visaFG>0
%    viWrite(visaFG, "*RST\n");
    viWrite(visaFG, ":FUNC SIN\n");         % sinewave
    viWrite(visaFG, ":FREQ +1000.0\n");     % 1kHz
    viWrite(visaFG, ":OUTP:LOAD 9.9E37\n"); % high impedance load
    viWrite(visaFG, ":VOLT:UNIT VPP\n");    % programming as VPP
    viWrite(visaFG, ":VOLT +1.0\n");        % 1.0 Vpp
    viWrite(visaFG, ":VOLT:OFFS +0.0\n");   % no offset
    viWrite(visaFG, ":VOLT:RANG:AUTO 1\n"); % output range (attenuator)
    viWrite(visaFG, ":BURS:STAT 0\n");      % no burst
    viWrite(visaFG, ":SWE:STAT 0\n");       % no sweep
    viWrite(visaFG, ":AM:STAT 0\n");        % no AM
    viWrite(visaFG, ":FM:STAT 0\n");        % no FM
    viWrite(visaFG, ":FSK:STAT 0\n");       % no FSK
    viWrite(visaFG, ":OUTP 1\n");           % output on
  else
    disp("  no connection to function generator");
  end
end
% open and initialze function generator in MSO2000 or MSO3000 series with defaults
function initScopeFG(source, event)
  global visaRM
  if visaRM==0
    visaRM = viOpenDefaultRM();
  end
  global visaMSO
  disp("initialize Scope function generator");
  if visaMSO==0 % device not open so far
    [visaMSO, status] = viOpen(visaRM, "MSO-USB", 5000, 10);
  end
  if visaMSO>0
%    viWrite(visaMSO, ":WGEN:RST\n"); % 1kHz sin, 500mVpp
    viWrite(visaMSO, ":WGEN:FUNC SIN\n");         % sinewave
    viWrite(visaMSO, ":WGEN:FREQ +1000.0\n");     % 1kHz
    viWrite(visaMSO, ":WGEN:OUTP:LOAD ONEMeg\n"); % high impedance load
    viWrite(visaMSO, ":WGEN:VOLT +1.0\n");        % 1.0 Vpp
    viWrite(visaMSO, ":WGEN:VOLT:OFFS +0.0\n");   % no offset
    viWrite(visaMSO, ":WGEN:MOD:STAT OFF\n");     % no modulation
    viWrite(visaMSO, ":WGEN:OUTP 1\n");           % output on
  else
    disp("  no connection to Scope function generator");
  end
end
if useScopeFG
  uimenu("text", "init &Generator", "accelerator", "g", "menuselectedfcn", @initScopeFG);
else
  uimenu("text", "init &Generator", "accelerator", "g", "menuselectedfcn", @initFG);
end

% load data for display
function openFile(source, event)
  selectedFile = uigetfile("*.bin", "select data to load");
  if ~isnumeric(selectedFile)
    load(selectedFile);
    global dataTable;
    set(dataTable, "data", data);
    updatePlot([], []);
  end
end
uimenu("text", "&Open file", "accelerator", "o", "menuselectedfcn", @openFile);

% save data for external processing
function saveFile(source, event)
  selectedFile = uiputfile("*.bin", "select file to save data");
  saveOK = 0;
  if isnumeric(selectedFile)
    saveOK = 0;
  elseif exist("selectedFile", "file")
    saveOK = (questdlg ("overwrite existing file?", "WARNING", "YES", "NO", "NO") == "YES");
  else
    saveOK = 1;
  end
  if saveOK
    global dataTable;
    data = get(dataTable, "data");
    save("-binary", selectedFile, "data");
  end
end
uimenu("text", "&Save file", "accelerator", "s", "menuselectedfcn", @saveFile);

% create empty data table with just freqency column filled
function data = defaultData()
  global configTable;
  config = get(configTable, "data"); % vector of numbers
  fStart = cell2mat(config(2,2));
  fStop = cell2mat(config(3,2));
  nPoints = cell2mat(config(4,2));
  logF = cell2mat(config(5,2));
  data = NA(nPoints, 6);
  if logF==1
    f = logspace(log10(fStart), log10(fStop), nPoints);
  else
    f = linspace(log10(fStart), log10(fStop), nPoints);
  end
  data(:,1) = f;
end
% set dataTable to defaults after change of parameters
function setDefaultData(source, event)
  global dataTable;
  data = defaultData();
  set(dataTable, "data", data);
end

% generate configuration table
global configTable;
configTable = uitable(uiFig,
  "tag", "parameters",
  "units", "normalized",
  "position", [0.0 0.1 0.26 0.9],
  "rowname", [],
  "rowstriping", "on",
  "columnname", {"parameter", "value", "unit"},
  "columnwidth", {80, 70, 50},
  "columneditable", [false true false],
  "data",
  {
    "GENERATOR", "", ""
    "f start", 100, "Hz"
    "f stop", 10000, "Hz"
    "n", 11, "Points"
    "log freq.?", 1, "1/0"
    "Ampl.", 1.0, "Vpp"
    "", "", ""
    "SCOPE", "", ""
    "channel", 1, "input"
    "channel", 2, "output"
  },
  "celleditcallback", @setDefaultData
);

% generate data table
global dataTable;
dataTable = uitable(uiFig,
  "tag", "data",
  "units", "normalized",
  "position", [0.26 0.0 0.74 1.0],
  "rowstriping", "on",
  "columnname", {"f [Hz]", "Vin [Vrms]", "Vout [Vrms]", "gain [1]", "gain [dB]" "phase [deg]"},
  "columnwidth", {90 90 90 90 90 90}
);

% update plot data displayed
function updatePlot(source, event)
  figure(2);
  clf;
  global dataTable;
  data = get(dataTable, "data");
  if rows(data)<1
    return; % no data to plot
  end
  styleControls = get(dataTable, "userdata");
  xStyle = get(styleControls(1), "value");
  yStyle = get(styleControls(2), "value");
  % magnitude
  hGain = subplot(2,1,1);
  switch yStyle
    case 3 % linear
      plot(data(:,1), data(:,4));
      ylabel("gain [1]");
    case 2 % log
      semilogy(data(:,1), data(:,4));
      ylabel("gain [1]");
    otherwise % dB
      plot(data(:,1), data(:,5));
      ylabel("gain [dB]");
  end
  grid on;
  xlabel("f [Hz]");
  % phase
  hPhase = subplot(2,1,2);
  plot(data(:,1), rad2deg(unwrap(deg2rad(data(:,6))))); grid on;
  xlabel("f [Hz]");
  ylabel("phase [deg]");
  switch xStyle
    case 2
    set(hGain, "XScale", "lin");
    set(hPhase, "XScale", "lin");
  otherwise
    set(hGain, "XScale", "log");
    set(hPhase, "XScale", "log");
  end
  linkaxes([hGain, hPhase], "x");
end

% X axis control
global xControl;
xControl = uicontrol(uiFig,
  "style", "popupmenu",
  "units", "normalized",
  "position", [0.0 0.1 0.26 0.1],
  "string", {"x Axis logarithmic", "x Axis linear"},
  "value", 1,
  "callback", @updatePlot
);
% Y axis control
global yControl;
yControl = uicontrol(uiFig,
  "style", "popupmenu",
  "units", "normalized",
  "position", [0.0 0.2 0.26 0.1],
  "string", {"y Axis dB", "y Axis logarithmic", "y Axis linear"},
  "value", 1,
  "callback", @updatePlot
);
% make available for updatePlot() function
set(dataTable, "userdata", [xControl, yControl]);

% helping functions

% change signal frequency
function FGsetFrequency(f)
  global visaFG;
  if visaFG>0
    viWrite(visaFG, [":FREQ " num2str(f) "\n"]);
  else
    disp("FGsetFrequency: function generator not initialized");
  end
end
function ScopeFGsetFrequency(f)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, [":WGEN:FREQ " num2str(f) "\n"]);
  else
    disp("ScopeFGsetFrequency: function generator not initialized");
  end
end
% change signal amplitude
function FGsetAmplitude(Vpp)
  global visaFG;
  if visaFG>0
    viWrite(visaFG, [":VOLT " num2str(Vpp) "\n"]);
  else
    disp("FGsetAmplitude: function generator not initialized");
  end
end
function ScopeFGsetAmplitude(Vpp)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, [":WGEN:VOLT " num2str(Vpp) "\n"]);
  else
    disp("ScopeFGsetAmplitude: function generator not initialized");
  end
end
% set up measurement values displayed on scope (just for user)
function MSOsetMeasurementDisplay(channelIn, channelOut)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, ":MEASure:CLEar\n");
    inString = ["CHAN" num2str(channelIn)];
    outString = ["CHAN" num2str(channelOut)];
%    viWrite(visaMSO, [":MEASure:VPP " num2str(channelIn)  "\n"]);
%    viWrite(visaMSO, [":MEASure:VPP " num2str(channelOut) "\n"]);
    viWrite(visaMSO, [":MEASure:VRMS CYCLe,AC," inString  "\n"]);
    viWrite(visaMSO, [":MEASure:VRMS CYCLe,AC," outString "\n"]);
    viWrite(visaMSO, [":MEASure:PHASe " outString "," inString "\n"]);
    viWrite(visaMSO, ":MEASure:SHOW ON\n");
    viWrite(visaMSO, [":" inString ":LAB  \"IN\"\n"]);
    viWrite(visaMSO, [":" outString ":LAB \"OUT\"\n"]);
    viWrite(visaMSO, ":DISPlay:LABel ON\n");       % display labels
    viWrite(visaMSO, [":TRIG:EDGE:SOURCE " inString "\n"]);  % trigger on channelIn
  end
end

% set time range of trace
function MSOsetTimeRange(seconds)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, [":TIM:RANGE " num2str(seconds) "\n"]);
  else
    disp("MSOsetTimeRange: scope not initialized");
  end
end

% set amplitude range (full scale)
function MSOsetAmpRange(channel, Vpp)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, [":CHAN" num2str(channel) ":RANGE " num2str(Vpp) "\n"]);
  else
    disp("MSOsetAmpRange: scope not initialized");
  end
end

% get results from scope, assuming valid time and y settings
function result = measure(channelIn, channelOut, f, Vpp)
  % NOTE f and Vpp used for simulation only
  global visaMSO;
  if visaMSO==0 % simulate data of low pass
    vIn = Vpp/sqrt(2);
    G = 1./(1+1i*f/1000);
    vOut = abs(Vpp*G);
    gain = abs(G);
    phase = rad2deg(arg(G));
  else % get actual data from scope
    % NOTE measuring RMS is more accurate than VPP in case of noise on any channel
    vIn = str2num(viQuery(visaMSO, [":MEAS:VRMS? CYCLe,AC,CHAN" num2str(channelIn) "\n"], 100));
    vOut = str2num(viQuery(visaMSO, [":MEAS:VRMS? CYCLe,AC,CHAN" num2str(channelOut) "\n"], 100));
    gain = abs(vOut/vIn);
    phase = str2num(viQuery(visaMSO, [":MEAS:PHASe? CHAN" num2str(channelOut) ",CHAN" num2str(channelIn) "\n"], 100));
    if phase>400
      phase = NA;
    end
  end
  gainDB = 20*log10(gain);
  result = [f vIn vOut gain gainDB phase];
end

% run a measurement by scanning all frequencies
function runPressed(source, event)
  global configTable;
  global dataTable;
  global visaMSO;
  global useScopeFG;
  % blank data table
  data = defaultData(); % blank table with frequencies to measure
  set(dataTable, "data", data);
  config = get(configTable, "data"); % vector of numbers in column 2
  % set up output level
  Vpp = cell2mat(config(6,2));
  if useScopeFG
    ScopeFGsetAmplitude(Vpp);
  else
    FGsetAmplitude(Vpp);
  end
  % get channels to use
  channelIn = cell2mat(config(9,2));
  channelOut = cell2mat(config(10,2));
  MSOsetMeasurementDisplay(channelIn, channelOut); % measurements on scope
  % actual settings for both channels
  inRange = str2num(viQuery(visaMSO, [":CHAN" num2str(channelIn) ":RANGE?"], 100));
  outRange = str2num(viQuery(visaMSO, [":CHAN" num2str(channelOut) ":RANGE?"], 100));
  f = data(:,1);
  for n = 1:length(f)
    if useScopeFG
      ScopeFGsetFrequency(f(n));
    else
      FGsetFrequency(f(n));
    end
    MSOsetTimeRange(2/f(n)); % set time range to 2 periods
    % adjust range on input channel
    stopAdjust = 0;
    for adjustLoop=1:10 % time out if not converging
      vppIn = str2num(viQuery(visaMSO, [":MEAS:VPP? CHAN" num2str(channelIn) "\n"], 100));
      if vppIn > 0.95*inRange
        inRange = inRange*2;
        if inRange>50
          inRange=50; stopAdjust=1;
        end
        MSOsetAmpRange(channelIn, inRange);
      elseif vppIn < 0.4*inRange
        inRange = inRange/2; % 1.2*vppIn;
        if inRange<0.08 % TODO we could accept 8 mV if using 1:1 probe
          inRange=0.08; stopAdjust=1;
        end
        MSOsetAmpRange(channelIn, inRange);
      else
        break;
      end
    end
    % adjust range on output channel
    stopAdjust = 0;
    for adjustLoop=1:10 % time out if not converging
      vppOut = str2num(viQuery(visaMSO, [":MEAS:VPP? CHAN" num2str(channelOut) "\n"], 100));
      if vppOut > 0.95*outRange
        outRange = outRange*2;
        if outRange>50
          outRange = 50; stopAdjust=1;
        end
        MSOsetAmpRange(channelOut, outRange);
      elseif vppOut < 0.4*outRange
        outRange = outRange/2; % 1.2*vppIn;
        if outRange < 0.08 % TODO we could accept 8 mV if using 1:1 probe
          outRange = 0.08; stopAdjust=1;
        end
        MSOsetAmpRange(channelOut, outRange);
      else
        break; % in expected range
      end
      if stopAdjust==1
        break;
      end
    end
    data(n,:) = measure(channelIn, channelOut, f(n), Vpp); % get measurements
    set(dataTable, "data", data); % show in table
  end
  updatePlot([], []); % trigger plot update
end

uicontrol(uiFig,
  "style", "pushbutton",
  "units", "normalized",
  "position", [0.0 0.0 0.26 0.1],
  "string", "RUN",
  "callback", @runPressed
);

