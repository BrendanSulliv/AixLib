within AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses;
model ModularCHP_PowerUnit_EASY_Experimental
  "Model of modular CHP power unit"
  import AixLib;

  replaceable package Medium_Fuel =
      AixLib.DataBase.CHP.ModularCHPEngineMedia.NaturalGasMixture_TypeAachen
                                                                    constrainedby
    DataBase.CHP.ModularCHPEngineMedia.CHPCombustionMixtureGasNasa
                                annotation(choicesAllMatching=true);
protected
  replaceable package Medium_Air =
      AixLib.DataBase.CHP.ModularCHPEngineMedia.EngineCombustionAir
                                                               constrainedby
    DataBase.CHP.ModularCHPEngineMedia.EngineCombustionAir
                         annotation(choicesAllMatching=true);

  replaceable package Medium_Exhaust =
      DataBase.CHP.ModularCHPEngineMedia.CHPFlueGasLambdaOnePlus  constrainedby
    DataBase.CHP.ModularCHPEngineMedia.CHPCombustionMixtureGasNasa
                                 annotation(choicesAllMatching=true);
public
  replaceable package Medium_Coolant =
      Modelica.Media.Air.DryAirNasa     constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true);

  parameter
    AixLib.DataBase.CHP.ModularCHPEngineData.CHPEngDataBaseRecord
    CHPEngineModel=DataBase.CHP.ModularCHPEngineData.CHP_Kirsch_L4_12()
    "CHP engine data for calculations"
    annotation (choicesAllMatching=true, Dialog(group="Unit properties"));

  parameter AixLib.Fluid.BoilerCHP.Data.ModularCHP.EngineMaterialData EngMat=
      AixLib.Fluid.BoilerCHP.Data.ModularCHP.EngineMaterial_CastIron()
    "Thermal engine material data for calculations"
    annotation (choicesAllMatching=true, Dialog(group="Unit properties"));

  inner Modelica.Fluid.System system(p_ambient=p_amb, T_ambient=T_amb)
    annotation (Placement(transformation(extent={{-100,-100},{-84,-84}})));

  Modelica.Fluid.Sources.FixedBoundary outletExhaustGas(
    redeclare package Medium = Medium_Exhaust,
    p=p_amb,
    nPorts=1)
    annotation (Placement(transformation(extent={{112,30},{92,50}})));

  parameter Modelica.SIunits.Temperature T_amb=298.15
    "Default ambient temperature"
    annotation (Dialog(group="Ambient Parameters"));
  parameter Modelica.SIunits.AbsolutePressure p_amb=101325
    "Default ambient pressure" annotation (Dialog(group="Ambient Parameters"));
  Modelica.SIunits.Temperature T_CoolRet=exhaustHeatExchanger.senTCooCold.T
    "Coolant return temperature";
  Modelica.SIunits.Temperature T_CooSup=submodel_CoolingEASY.senTCooEngOut.T
    "Coolant supply temperature";
  Modelica.SIunits.Power Q_Therm=if (submodel_CoolingEASY.heatPort_outside.Q_flow
       + exhaustHeatExchanger.pipeCoolant.heatPort_outside.Q_flow) > 10 then
      submodel_CoolingEASY.heatPort_outside.Q_flow + exhaustHeatExchanger.pipeCoolant.heatPort_outside.Q_flow
       else 1 "Thermal power output of the CHP unit";
  Modelica.SIunits.Power P_Mech=gasolineEngineChp.cHPCombustionEngine.P_eff "Mechanical power output of the CHP unit";
  Modelica.SIunits.Power P_El=-inductionMachine.P_E
    "Electrical power output of the CHP unit";
  Modelica.SIunits.Power P_Fuel=if (gasolineEngineChp.cHPEngBus.isOn) then
      m_flow_Fue*Medium_Fuel.H_U else 0 "CHP fuel expenses";
  Modelica.SIunits.Power Q_TotUnused=gasolineEngineChp.cHPCombustionEngine.Q_therm-gasolineEngineChp.engineToCoolant.actualHeatFlowEngine.Q_flow+exhaustHeatExchanger.volExhaust.heatPort.Q_flow "Total heat error of the CHP unit";
 // Modelica.SIunits.Power Q_ExhUnused=exhaustHeatExchanger.volExhaust.ports_H_flow[1]+exhaustHeatExchanger.volExhaust.ports_H_flow[2]+exhaustHeatExchanger.volExhaust.heatPort.Q_flow "Total exhaust heat error";
  Modelica.SIunits.MassFlowRate m_flow_CO2=gasolineEngineChp.cHPCombustionEngine.m_flow_CO2Exh
    "CO2 emission output rate";
  Modelica.SIunits.MassFlowRate m_flow_Fue=if (gasolineEngineChp.cHPCombustionEngine.m_flow_Fue)
       > 0.0001 then gasolineEngineChp.cHPCombustionEngine.m_flow_Fue else
      0.0001 "Fuel consumption rate of CHP unit";
  type SpecificEmission=Real(final unit="g/(kW.h)", min=0.0001);
  SpecificEmission b_CO2=if noEvent(abs(Q_Therm + P_El) > 0) then 3600000000*
      m_flow_CO2/(Q_Therm + P_El) else 0
    "Specific CO2 emissions per kWh (heat and power)";
  SpecificEmission b_e=if noEvent(abs(Q_Therm + P_El) > 0) then 3600000000*
      m_flow_Fue/(Q_Therm + P_El) else 0
    "Specific fuel consumption per kWh (heat and power)";
  Real FueUtiRate=(Q_Therm + P_El)/(m_flow_Fue*Medium_Fuel.H_U)
    "Fuel utilization rate of the CHP unit";
  Real PowHeatRatio = P_El/Q_Therm "Power to heat ration of the CHP unit";
  Real eta_Therm=Q_Therm/(m_flow_Fue*Medium_Fuel.H_U)
    "Thermal efficiency of the CHP unit";
  Real eta_Mech=P_Mech/(m_flow_Fue*Medium_Fuel.H_U)
    "Mechanical efficiency of the CHP unit";
  Real eta_El=P_El/(m_flow_Fue*Medium_Fuel.H_U)
    "Mechanical efficiency of the CHP unit";

  parameter Real s_til=abs((inductionMachine.s_nominal*(inductionMachine.M_til/
      inductionMachine.M_nominal) + inductionMachine.s_nominal*sqrt(abs(((
      inductionMachine.M_til/inductionMachine.M_nominal)^2) - 1 + 2*
      inductionMachine.s_nominal*((inductionMachine.M_til/inductionMachine.M_nominal)
       - 1))))/(1 - 2*inductionMachine.s_nominal*((inductionMachine.M_til/
      inductionMachine.M_nominal) - 1))) "Tilting slip of electric machine"
    annotation (Dialog(tab="Calibration parameters", group="Fast calibration - Electric power and fuel usage"));
  parameter Real calFac=1
    "Calibration factor for electric power output (default=1)"
    annotation (Dialog(tab="Calibration parameters",
    group="Fast calibration - Electric power and fuel usage"));
  parameter Modelica.SIunits.ThermalConductance GEngToCoo=33
    "Thermal conductance of engine housing from the cylinder wall to the water cooling channels"
    annotation (Dialog(tab="Calibration parameters",group=
          "Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.ThermalConductance GCooExhHex=400
    "Thermal conductance of exhaust heat exchanger to cooling circuit"
    annotation (Dialog(tab="Calibration parameters",group=
          "Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.Mass mEng=CHPEngineModel.mEng
    "Total engine mass for heat capacity calculation"
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
  parameter Modelica.SIunits.HeatCapacity CExhHex=50000
    "Heat capacity of exhaust heat exchanger(default= 4000 J/K)" annotation (
     Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Modelica.SIunits.Thickness dInn=0.01
    "Typical value for the thickness of the cylinder wall (between combustion chamber and cooling circle)"
    annotation (Dialog(tab="Calibration parameters",group="Fast calibration - Thermal power output"));
  parameter Modelica.SIunits.ThermalConductance GEngToAmb=0.23
    "Thermal conductance from engine housing to the surrounding air"
    annotation (Dialog(tab="Calibration parameters",group=
          "Advanced calibration parameters"));
  parameter Modelica.SIunits.ThermalConductance GAmb=5
    "Constant thermal conductance of material" annotation (Dialog(tab=
          "Calibration parameters",
        group="Advanced calibration parameters"));
//  parameter Modelica.SIunits.Temperature T_HeaRet = 303.15
//    "Constant heating circuit return temperature"
//    annotation (Dialog(tab="Engine Cooling Circle"));
  parameter Modelica.SIunits.Area A_surExhHea=50
    "Surface for exhaust heat transfer"
    annotation (Dialog(tab="Calibration parameters",group="Advanced calibration parameters"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate m_flow=
      CHPEngineModel.m_floCooNominal
    "Nominal mass flow rate of coolant inside the engine cooling circle" annotation (Dialog(tab=
          "Calibration parameters", group="Advanced calibration parameters"));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature ambientTemperature(T=
       T_amb)
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor
    annotation (Placement(transformation(extent={{-52,-8},{-68,8}})));
  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.ExhaustHeatExchanger
    exhaustHeatExchanger(
    pipeCoolant(
      p_a_start=system.p_start,
      p_b_start=system.p_start,
      use_HeatTransferConvective=false,
      isEmbedded=true,
      diameter=CHPEngineModel.dCoo,
      allowFlowReversal=allowFlowReversalCoolant),
    T_Amb=T_amb,
    p_Amb=p_amb,
    redeclare package Medium3 = Medium_Exhaust,
    redeclare package Medium4 = Medium_Coolant,
    d_iExh=CHPEngineModel.dExh,
    dp_CooExhHex=CHPEngineModel.dp_Coo,
    heatConvExhaustPipeInside(length=exhaustHeatExchanger.l_ExhHex),
    volExhaust(V=exhaustHeatExchanger.VExhHex),
    CHPEngData=CHPEngineModel,
    M_Exh=gasolineEngineChp.cHPCombustionEngine.MM_Exh,
    allowFlowReversal1=allowFlowReversalExhaust,
    allowFlowReversal2=allowFlowReversalCoolant,
    m1_flow_small=mExh_flow_small,
    m2_flow_small=mCool_flow_small,
    ConTec=ConTec,
    A_surExhHea=A_surExhHea,
    m2_flow_nominal=m_flow,
    CExhHex=CExhHex,
    GCoo=GCooExhHex,
    GAmb=GAmb) annotation (Placement(transformation(extent={{40,4},{68,32}})));

  parameter Boolean ConTec=false
    "Is condensing technology used and should latent heat be considered?"
    annotation (Dialog(tab="Advanced", group="Latent heat use"));
  parameter Boolean useGenHea=true
    "Is the thermal loss energy of the elctric machine used?"
    annotation (Dialog(tab="Advanced", group="Generator heat use"));
  parameter Boolean allowFlowReversalExhaust=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal for exhaust medium"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Boolean allowFlowReversalCoolant=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal for coolant medium"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mExh_flow_small=0.0001
    "Small exhaust mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mCool_flow_small=0.0001
    "Small coolant mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.CHP_ElectricMachine
    inductionMachine(
    CHPEngData=CHPEngineModel,
    useHeat=useGenHea,
    calFac=calFac,
    s_til=s_til)
    annotation (Placement(transformation(extent={{-66,12},{-36,42}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_retCoo(redeclare package Medium =
        Medium_Coolant)
    annotation (Placement(transformation(extent={{-90,-68},{-70,-48}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_supCoo(redeclare package Medium =
        Medium_Coolant)
    annotation (Placement(transformation(extent={{70,-68},{90,-48}})));
  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.GasolineEngineChp
    gasolineEngineChp(
    redeclare package Medium_Fuel = Medium_Fuel,
    redeclare package Medium_Air = Medium_Air,
    redeclare package Medium_Exhaust = Medium_Exhaust,
    CHPEngineModel=CHPEngineModel,
    EngMat=EngMat,
    T_amb=T_amb,
    mEng=mEng,
    dInn=dInn,
    GEngToAmb=GEngToAmb,
    cHPCombustionEngine(
      T_Amb=gasolineEngineChp.T_amb,
      T_logEngCool=gasolineEngineChp.T_logEngCoo,
      T_ExhCHPOut=gasolineEngineChp.T_ExhCHPOut),
    engineToCoolant(T_ExhPowUniOut=gasolineEngineChp.T_ExhCHPOut))
                         annotation (Placement(transformation(rotation=0,
          extent={{-18,8},{18,44}})));
  AixLib.Controls.Interfaces.CHPControlBus     sigBusCHP(
    meaThePowChp=Q_Therm,
    meaTemRetCooChp=T_CoolRet,
    meaTemSupCooChp=T_CooSup,
    calEmiCO2Chp=b_CO2,
    calFueChp=b_e,
    calEtaTheChp=eta_Therm,
    calEtaElChp=eta_El,
    calFueUtiChp=FueUtiRate) annotation (Placement(transformation(extent={{-28,68},
            {26,118}}), iconTransformation(extent={{-28,68},{26,118}})));

  AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses.Submodel_CoolingEASY
    submodel_CoolingEASY(
    sigBus_coo(meaTemInEng=submodel_CoolingEASY.senTCooEngIn.T, meaTemOutEng=
          submodel_CoolingEASY.senTCooEngOut.T),
    redeclare package Medium_Coolant = Medium_Coolant,
    CHPEngineModel=CHPEngineModel,
    m_flow=m_flow,
    GEngToCoo=GEngToCoo,
    allowFlowReversalCoolant=allowFlowReversalCoolant,
    mCool_flow_small=mCool_flow_small) annotation (Placement(transformation(
          rotation=0, extent={{14,-72},{42,-44}})));

equation
  connect(ambientTemperature.port, heatFlowSensor.port_b)
    annotation (Line(points={{-80,0},{-68,0}}, color={191,0,0}));
  connect(inductionMachine.flange_genIn, gasolineEngineChp.flange_eng)
    annotation (Line(points={{-36,27},{-18.72,27},{-18.72,26.72}}, color={0,0,
          0}));
  connect(gasolineEngineChp.port_exh, exhaustHeatExchanger.port_a1)
    annotation (Line(points={{18.36,26.36},{28,26.36},{28,26.4},{40,26.4}},
        color={0,127,255}));
  connect(gasolineEngineChp.port_amb, heatFlowSensor.port_a)
    annotation (Line(points={{0,9.8},{0,0},{-52,0}}, color={191,0,0}));
  connect(gasolineEngineChp.port_cooCir, submodel_CoolingEASY.heatPort_outside)
    annotation (Line(points={{18,10.16},{18,-6},{-10,-6},{-10,-76},{28,-76},{
          28,-65.56}}, color={191,0,0}));
  connect(exhaustHeatExchanger.port_amb, heatFlowSensor.port_a) annotation (
      Line(points={{40,18},{30,18},{30,0},{-52,0}}, color={191,0,0}));
  connect(inductionMachine.cHPGenBus, sigBusCHP) annotation (Line(
      points={{-62.4,27},{-70,27},{-70,93},{-1,93}},
      color={255,204,51},
      thickness=0.5), Text(
      string="",
      index=1,
      extent={{6,3},{6,3}}));
  connect(exhaustHeatExchanger.cHPExhHexBus, sigBusCHP) annotation (Line(
      points={{54,31.86},{54,93},{-1,93}},
      color={255,204,51},
      thickness=0.5), Text(
      string="",
      index=1,
      extent={{6,3},{6,3}}));
  connect(gasolineEngineChp.cHPEngBus, sigBusCHP) annotation (Line(
      points={{0,41.84},{-1,41.84},{-1,93}},
      color={255,204,51},
      thickness=0.5), Text(
      string="",
      index=1,
      extent={{6,3},{6,3}}));
  connect(port_supCoo, submodel_CoolingEASY.port_b)
    annotation (Line(points={{80,-58},{42,-58}}, color={0,127,255}));
  connect(exhaustHeatExchanger.port_b2, submodel_CoolingEASY.port_a)
    annotation (Line(points={{40,9.6},{34,9.6},{34,-12},{0,-12},{0,-58},{14,-58}},
        color={0,127,255}));
  connect(submodel_CoolingEASY.sigBus_coo, sigBusCHP) annotation (Line(
      points={{28.14,-50.44},{28.14,93},{-1,93}},
      color={255,204,51},
      thickness=0.5));
  connect(port_retCoo, exhaustHeatExchanger.port_a2) annotation (Line(points={{
          -80,-58},{-40,-58},{-40,-90},{100,-90},{100,9.6},{68,9.6}}, color={0,
          127,255}));
  connect(exhaustHeatExchanger.port_b1, outletExhaustGas.ports[1])
    annotation (Line(points={{68,26.4},{80,26.4},{80,40},{92,40}}, color={0,
          127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
          extent={{-50,58},{50,18}},
          lineColor={255,255,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={175,175,175},
          textString="CHP",
          textStyle={TextStyle.Bold}),
                              Rectangle(
          extent={{-80,80},{80,-100}},
          lineColor={0,0,0},
          fillPattern=FillPattern.VerticalCylinder,
          fillColor={170,170,255}),                                       Text(
          extent={{-50,68},{50,28}},
          lineColor={255,255,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={175,175,175},
          textStyle={TextStyle.Bold},
          textString="Modular
CHP"),  Rectangle(
          extent={{-12,6},{12,-36}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-10,-16},{-10,-36},{-8,-30},{8,-30},{10,-36},{10,-16},{-10,-16}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-2,-26},{4,-32}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-18,-54},{-8,-64}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-2,-30},{-14,-54},{-10,-56},{0,-32},{-2,-30}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-4.5,-15.5},{-8,-10},{0,4},{6,-4},{10,-4},{8,-8},{8,-12},{5.5,
              -15.5},{-4.5,-15.5}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={255,127,0}),
        Polygon(
          points={{-4.5,-13.5},{0,-4},{6,-10},{2,-14},{-4.5,-13.5}},
          lineColor={255,255,170},
          fillColor={255,255,170},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false)),
         __Dymola_Commands(file="Modelica://AixLib/Resources/Scripts/Dymola/Fluid/CHP/Examples/CHP_OverviewScript.mos" "QuickOverviewSimulateAndPlot"),
    Documentation(info="<html>
<p>This model shows the implementation of a holistic overall model for a CHP power unit using the example of the Kirsch L4.12. The model is able to map different gas engine CHPs of small and medium power classes (&lt; 200 kWel). It allows an investigation of the thermal and electrical dynamics of the individual components and the entire plant. In addition, a CO2 balance can be calculated for the comparison of different control strategies. </p>
<p>The modular CHP model is aggregated from closed submodels that can be run on their own. These are based on physical calculation approaches and offer mechanical, material and thermal interfaces. The thermal interconnection of the exhaust gas heat exchanger and combustion engine in the internal primary circuit is freely selectable. Detailed explanations of how the submodels work are provided in their documentation. Parameterization and control are realized on the highest model level using bus ports to transmit measured and calculated signals throughout the different hierarchical model levels.</p>
<h4><span style=\"color: #000000\">Calibration:</span></h4>
<p>If the calibration of the model is not to be performed for all listed calibration quantities, a quick adaptation of the essential model quantities for the use of are carried out. Setting the speed of the generator and internal combustion engine for the nominal power point using the calibration variables tilting slip, electrical calibration factor and modulation factor results in a high correspondence for electrical power and fuel input for each power stage of the CHP. The thermal output can then be checked by checking the flue gas temperature when the system exits. The examination of the data sheets of some cogeneration units provides general comparative values for the flue gas temperature in a range around 50 &deg;C with and around 110 &deg;C without condensing utilisation at rated output. The flue gas temperature can mainly be adjusted using the heat transitions G_CoolChannel and G_CooExhHex. Finally, the parameters of the heat exchanger can be adapted to the heating circuit.</p>
<h4><span style=\"color: #000000\">Limitations:</span></h4>
<p>Supercharged internal combustion engines and diesel engines cannot be completely mapped.</p>
</html>"));
end ModularCHP_PowerUnit_EASY_Experimental;