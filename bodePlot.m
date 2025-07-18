% Agilent 33250A / MSO-X 2024 bode plotter

% 33250A *LRN? string, send *RST before to ensure proper processing
% Return Count: 1086 bytes
%  :FUNC:SQU:DCYC +5.0000000000000E+01;
%  :FUNC:RAMP:SYMM +1.0000000000000E+02;
%  :FUNC:USER SCHOTTER_20;
%  :FUNC SIN;
%  :FREQ +1.0000000000000E+02;
%  :PULS:WIDT +1.0000000000000E-03;
%  :PULS:TRAN +5.0000000000000E-09;
%  :OUTP:LOAD 9.9E37;
%  :VOLT:UNIT VPP;
%  :VOLT +5.0000000000000E+00;
%  :VOLT:OFFS +0.0000000000000E+00;
%  :VOLT:RANG:AUTO 1;
%  :TRIG:SOUR BUS;
%  :TRIG:SLOP POS;
%  :TRIG:DEL +0.0000000000000E+00;
%  :UNIT:ANGL DEG;
%  :BURS:MODE TRIG;
%  :BURS:NCYC +1.0000000000000E+00;
%  :BURS:PHAS +0.0000000000000E+00;
%  :BURS:INT:PER +4.0000000000000E+00;
%  :BURS:GATE:POL NORM;
%  :BURS:STAT 0;
%  :FREQ:STAR +4.0000000000000E+03;
%  :FREQ:STOP +5.0000000000000E+03;
%  :MARK 0;
%  :MARK:FREQ +5.0000000000000E+02;
%  :SWE:SPAC LIN;
%  :SWE:TIME +2.0000000000000E+00;
%  :SWE:STAT 0;
%  :AM:DEPT +1.0000000000000E+02;
%  :AM:SOUR INT;
%  :AM:INT:FREQ +2.0000000000000E+04;
%  :AM:INT:FUNC SIN;
%  :AM:STAT 0;
%  :FM:DEV +1.8300000000000E+04;
%  :FM:SOUR INT;
%  :FM:INT:FREQ +5.0000000000000E+03;
%  :FM:INT:FUNC SIN;
%  :FM:STAT 0;
%  :FSK:FREQ +1.0000000000000E+02;
%  :FSK:SOUR INT;
%  :FSK:INT:RATE +1.0000000000000E+01;
%  :FSK:STAT 0;
%  :OUTP 1;
%  :OUTP:POL NORM;
%  :OUTP:SYNC 1;
%  :OUTP:TRIG:SLOP POS;
%  :OUTP:TRIG 0;
%  :FORM:BORD NORM;
%  :DISP 1.

global visaRM
global visaFG
global visaMSO

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
visaFG  = int32(0); % VISA handle to function generator
visaMSO = int32(0); % VISA handle to scope

% set up GUI layout
uiFig = figure(1,
  "name", "bode plotter",
  "toolbar", "none",
  "menubar", "none",
  "position", [24 206 780 500]
);
clf;

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
    viWrite(visaFG, ":FUNC SIN\n");
    viWrite(visaFG, ":FREQ +1000.0\n");
    viWrite(visaFG, ":OUTP:LOAD 9.9E37\n");
    viWrite(visaFG, ":VOLT:UNIT VPP\n");
    viWrite(visaFG, ":VOLT +0.1\n");
    viWrite(visaFG, ":VOLT:OFFS +0.0\n");
    viWrite(visaFG, ":VOLT:RANG:AUTO 1\n");
    viWrite(visaFG, ":BURS:STAT 0\n");
    viWrite(visaFG, ":SWE:STAT 0\n");
    viWrite(visaFG, ":AM:STAT 0\n");
    viWrite(visaFG, ":FM:STAT 0\n");
    viWrite(visaFG, ":FSK:STAT 0\n");
    viWrite(visaFG, ":OUTP 1\n");
  else
    disp("  no connection to function generator");
  end
end
uimenu("text", "init &Generator", "accelerator", "g", "menuselectedfcn", @initFG);

function MSO = initMSO(source, event)
  global visaRM;
  if visaRM==0
    visaRM = viOpenDefaultRM();
  end
  global visaMSO;
  disp("initialize scope");
  if visaMSO==0
    [visaMSO, status] = viOpen(visaRM, "MSO-USB");
  end
  if visaMSO>0
    viWrite(visaMSO, ":CHAN1:DISP ON\n");
    viWrite(visaMSO, ":CHAN1:BWLimit ON\n");
    viWrite(visaMSO, ":CHAN1:COUPling AC\n");    % enable channels
    viWrite(visaMSO, ":CHAN1:RANGE 8.0\n");  % full scale range (V or A)
    viWrite(visaMSO, ":CHAN1:OFFset 0.0\n");   % V or A
    viWrite(visaMSO, ":CHAN1:UNIT VOLT\n");
    viWrite(visaMSO, ":CHAN1:LAB \"IN\"");    %   coupling AC

    viWrite(visaMSO, ":CHAN2:DISP ON\n");
    viWrite(visaMSO, ":CHAN2:BWLimit ON\n");
    viWrite(visaMSO, ":CHAN2:COUPling AC\n");    % enable channels
    viWrite(visaMSO, ":CHAN2:RANGE 8.0\n");  % full scale range (V or A)
    viWrite(visaMSO, ":CHAN2:OFFset 0.0\n");   % V or A
    viWrite(visaMSO, ":CHAN2:UNIT VOLT\n");
    viWrite(visaMSO, ":CHAN2:LAB \"OUT\"");    %   coupling AC

    viWrite(visaMSO, ":DISPlay:LABel ON\n");

    viWrite(visaMSO, ":TRIG:MODE EDGE\n");
    viWrite(visaMSO, ":TRIG:EDGE:SLOP POS\n");
    viWrite(visaMSO, ":TRIG:EDGE:LEV 0,CHAN1\n");

    viWrite(visaMSO, ":TIM:REFerence CENTer\n");
    viWrite(visaMSO, ":TIM:RANGE 0.005\n");   % full screen

    viWrite(visaMSO, ":MEASure:CLEar\n");
    viWrite(visaMSO, ":MEASure:PHASe CHAN1,CHAN2\n");
    viWrite(visaMSO, ":MEASure:SHOW ON\n");
    % :MEASure:SOURce CHAN1
    viWrite(visaMSO, ":MEASure:VPP CHAN1\n");
%    viWrite(visaMSO, ":MEASure:VRMS CYCLe,AC,CHAN1\n");
    viWrite(visaMSO, ":MEASure:VPP CHAN2\n");
%    viWrite(visaMSO, ":MEASure:VRMS CYCLe,AC,CHAN2\n");
  else
    disp("  no connection to scope");
  end
end
uimenu("text", "init &MSO", "accelerator", "m", "menuselectedfcn", @initMSO);

function openFile(source, event)
  selectedFile = uigetfile("*.bin", "select data to load");
  if ~isnumeric(selectedFile)
    load(selectedFile);
    global dataTable;
    set(dataTable, "data", data);
  end
end
uimenu("text", "&Open file", "accelerator", "o", "menuselectedfcn", @openFile);

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
    "f start", 100, "Hz"
    "f stop", 10000, "Hz"
    "n", 11, "Points"
    "log freq.?", 1, "1/0"
    "Ampl.", 1.0, "Vpp"
    "CHAN", 1, "input"
    "CHAN", 2, "output"
  }
);

global dataTable;
dataTable = uitable(uiFig,
  "tag", "data",
  "units", "normalized",
  "position", [0.26 0.0 0.74 1.0],
  "rowstriping", "on",
  "columnname", {"f", "in", "out", "gain", "gain [dB]" "phase"},
  "columnwidth", {90 90 90 90 90 90}
);

% helping functions
function FGsetFrequency(f)
  global visaFG;
  if visaFG>0
    viWrite(visaFG, [":FREQ " num2str(f) "\n"]);
  else
    disp("FGsetFrequency: function generator not initialized");
  end
end

function FGsetAmplitude(Vpp)
  global visaFG;
  if visaFG>0
    viWrite(visaFG, [":VOLT " num2str(Vpp) "\n"]);
  else
    disp("FGsetAmplitude: function generator not initialized");
  end
end

function MSOsetTimeRange(seconds)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, ["TIM:RANGE " num2str(seconds) "\n"]);
  else
    disp("MSOsetTimeRange: scope not initialized");
  end
end

function MSOsetAmpRange(channel, Vpp)
  global visaMSO;
  if visaMSO>0
    viWrite(visaMSO, [":CHAN" num2str(channel) ":RANGE " num2str(Vpp) "\n"]);
  else
    disp("MSOsetAmpRange: scope not initialized");
  end
end

function result = measure(f, Vpp, channelIn, channelOut)
  switch 0
    case 0 % simulated
      vIn = Vpp;
      G = 1./(1+1i*f/1000);
      vOut = abs(Vpp*G);
      gain = abs(G);
      gainDB = 20*log10(gain);
      phase = rad2deg(arg(G));
      result = [f vIn vOut gain gainDB phase];
    otherwise % use scope
  end
end

function runPressed(source, event)
  global configTable;
  global visaMSO;
  config = cell2mat(get(configTable, "data")(:,2)); % vector of numbers
  fStart = config(1);
  fStop = config(2);
  nPoints = config(3);
  logF = config(4);
  Vpp = config(5);
  channelIn = config(6);
  channelOut = config(7);
  if logF==1
    f = logspace(log10(fStart), log10(fStop), nPoints);
  else
    f = linspace(log10(fStart), log10(fStop), nPoints);
  end
  FGsetAmplitude(Vpp);
  global dataTable;
  data = NA(nPoints, 6);
  data(:,1) = f;
  set(dataTable, "data", data);
  inRange = str2num(viQuery(visaMSO, [":CHAN" num2str(channelIn) ":RANGE?"], 100))
  outRange = str2num(viQuery(visaMSO, [":CHAN" num2str(channelOut) ":RANGE?"], 100))
  for n = 1:length(f)
    FGsetFrequency(f(n));
    MSOsetTimeRange(2/f(n)); % set time range
    % TODO adjust scopesettings if level is too low or high
    % adjust range on input channel
    while (inRange>0.010) && (inRange<100)
      vppIn = str2num(viQuery(visaMSO, [":MEAS:VPP? CHAN" num2str(channelIn) "\n"], 100));
      if vppIn > 0.95*inRange
        inRange = inRange*2;
        MSOsetAmpRange(channelIn, inRange);
      elseif vppIn < 0.4*inRange
        inRange = inRange/2; % 1.2*vppIn;
        MSOsetAmpRange(channelIn, inRange);
      else
        break;
      end
    end
    % adjust range on output channel
    while (outRange>0.010) && (outRange<100)
      vppOut = str2num(viQuery(visaMSO, [":MEAS:VPP? CHAN" num2str(channelOut) "\n"], 100))
      if vppOut > 0.95*inRange
        outRange = outRange*2;
        MSOsetAmpRange(channelIn, outRange);
      elseif vppOut < 0.4*outRange
        outRange = outRange/2; % 1.2*vppIn;
        MSOsetAmpRange(channelIn, outRange);
      else
        break;
      end
    end
    data(n,:) = measure(f(n), Vpp, channelIn, channelOut);
    set(dataTable, "data", data);
    pause(0.5);
  end
end
% runButton =
uicontrol(uiFig,
  "units", "normalized",
  "position", [0.0 0.0 0.26 0.1],
  "string", "RUN",
  "callback", @runPressed
);

