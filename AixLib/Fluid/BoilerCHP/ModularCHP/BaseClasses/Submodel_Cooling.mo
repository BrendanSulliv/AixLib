within AixLib.Fluid.BoilerCHP.ModularCHP.BaseClasses;
model Submodel_Cooling
  import AixLib;
  Modelica.Fluid.Sensors.TemperatureTwoPort senTCooEngIn(
    redeclare package Medium = Medium_Coolant,
    allowFlowReversal=allowFlowReversalCoolant,
    m_flow_nominal=m_flow,
    m_flow_small=mCool_flow_small) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-60,0})));
  FixedResistances.Pipe engineHeatTransfer(
    redeclare package Medium = Medium_Coolant,
    redeclare model FlowModel =
        Modelica.Fluid.Pipes.BaseClasses.FlowModels.NominalLaminarFlow (
          dp_nominal=CHPEngineModel.dp_Coo, m_flow_nominal=m_flow),
    Heat_Loss_To_Ambient=true,
    alpha=engineHeatTransfer.alpha_i,
    eps=0,
    isEmbedded=true,
    use_HeatTransferConvective=false,
    p_a_start=system.p_start,
    p_b_start=system.p_start,
    alpha_i=GEngToCoo/(engineHeatTransfer.perimeter*engineHeatTransfer.length),
    diameter=CHPEngineModel.dCoo,
    allowFlowReversal=allowFlowReversalCoolant)
    annotation (Placement(transformation(extent={{8,12},{32,-12}})));

  Modelica.Fluid.Sensors.TemperatureTwoPort senTCooEngOut(
    redeclare package Medium = Medium_Coolant,
    allowFlowReversal=allowFlowReversalCoolant,
    m_flow_nominal=m_flow,
    m_flow_small=mCool_flow_small)
    annotation (Placement(transformation(extent={{50,-10},{70,10}})));
  replaceable package Medium_Coolant =
      DataBase.CHP.ModularCHPEngineMedia.CHPCoolantPropyleneGlycolWater (
                                 property_T=356, X_a=0.50) constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true);
  parameter
    DataBase.CHP.ModularCHPEngineData.CHPEngDataBaseRecord
    CHPEngineModel=DataBase.CHP.ModularCHPEngineData.CHP_ECPowerXRGI15()
    "CHP engine data for calculations"
    annotation (choicesAllMatching=true, Dialog(group="Unit properties"));
  outer Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{-100,-100},{-84,-84}})));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate m_flow=
      CHPEngineModel.m_floCooNominal
    "Nominal mass flow rate of coolant inside the engine cooling circle" annotation (Dialog(tab="Engine Cooling Circle"));
  parameter Modelica.SIunits.ThermalConductance GEngToCoo=45
    "Thermal conductance of engine housing from the cylinder wall to the water cooling channels"
    annotation (Dialog(tab="Engine Cooling Circle", group=
          "Calibration Parameters"));
  parameter Modelica.SIunits.Temperature T_HeaRet=303.15
    "Constant heating circuit return temperature"
    annotation (Dialog(tab="Engine Cooling Circle"));
  parameter Boolean allowFlowReversalCoolant=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal for coolant medium"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  parameter Modelica.Media.Interfaces.PartialMedium.MassFlowRate
    mCool_flow_small=0.0001
    "Small coolant mass flow rate for regularization of zero flow"
    annotation (Dialog(tab="Advanced", group="Assumptions"));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort_outside
    annotation (Placement(transformation(rotation=0, extent={{-10,-70},{10,-50}}),
        iconTransformation(extent={{-12,-66},{12,-42}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
        Medium_Coolant) annotation (Placement(transformation(rotation=0, extent=
           {{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium =
        Medium_Coolant) annotation (Placement(transformation(rotation=0, extent=
           {{90,-10},{110,10}})));
  AixLib.Controls.Interfaces.CHPControlBus sigBus_coo(meaTemInEng=
        senTCooEngIn.T, meaTemOutEng=senTCooEngOut.T) annotation (Placement(
        transformation(extent={{-28,26},{28,80}}), iconTransformation(extent=
            {{-28,26},{30,82}})));
  Movers.FlowControlled_m_flow                coolantPump(
    m_flow_small=mCool_flow_small,
    redeclare package Medium = Medium_Coolant,
    dp_nominal=CHPEngineModel.dp_Coo,
    allowFlowReversal=allowFlowReversalCoolant,
    addPowerToMedium=false,
    m_flow_nominal=m_flow)
    annotation (Placement(transformation(extent={{-30,12},{-10,-12}})));
  Modelica.Fluid.Sources.FixedBoundary fixedPressureLevel(
    nPorts=1,
    redeclare package Medium = Medium_Coolant,
    T(displayUnit="K") = T_HeaRet,
    p=300000)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-40})));
  Modelica.Blocks.Sources.RealExpression massFlowCoolant(y=if sigBus_coo.isOnPump
         then m_flow else mCool_flow_small)
    annotation (Placement(transformation(extent={{12,-50},{-8,-30}})));
equation
  connect(engineHeatTransfer.port_b, senTCooEngOut.port_a)
    annotation (Line(points={{32.48,0},{50,0}},     color={0,127,255}));
  connect(heatPort_outside, engineHeatTransfer.heatPort_outside) annotation (
      Line(points={{0,-60},{21.92,-60},{21.92,-6.72}},          color={191,0,0}));
  connect(port_a, senTCooEngIn.port_a)
    annotation (Line(points={{-100,0},{-70,0}}, color={0,127,255}));
  connect(port_b, senTCooEngOut.port_b)
    annotation (Line(points={{100,0},{70,0}}, color={0,127,255}));
  connect(senTCooEngIn.port_b, coolantPump.port_a)
    annotation (Line(points={{-50,0},{-30,0}}, color={0,127,255}));
  connect(engineHeatTransfer.port_a, coolantPump.port_b)
    annotation (Line(points={{7.52,0},{-10,0}}, color={0,127,255}));
  connect(massFlowCoolant.y, coolantPump.m_flow_in) annotation (Line(points={{-9,
          -40},{-20,-40},{-20,-14.4}}, color={0,0,127}));
  connect(fixedPressureLevel.ports[1], senTCooEngIn.port_a)
    annotation (Line(points={{-80,-30},{-80,0},{-70,0}}, color={0,127,255}));
  annotation (Icon(graphics={    Text(
          extent={{-151,113},{149,73}},
          lineColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255},
          textString="%name"),
        Line(
          points={{-60,32},{60,32},{60,32},{60,-32},{-60,-32},{-60,32}},
          color={0,127,255},
          thickness=0.5),
        Line(
          points={{60,-10},{60,14}},
          color={0,127,255},
          arrow={Arrow.Open,Arrow.None},
          thickness=0.5),
        Line(
          points={{0,7},{0,-15}},
          color={0,127,255},
          arrow={Arrow.Open,Arrow.None},
          origin={-60,3},
          rotation=360,
          thickness=0.5),
        Line(
          points={{0,7},{0,-15}},
          color={0,127,255},
          arrow={Arrow.Open,Arrow.None},
          origin={-4,-31},
          rotation=90,
          thickness=0.5),
        Line(
          points={{7,0},{-15,0}},
          color={0,127,255},
          arrow={Arrow.Open,Arrow.None},
          origin={4,31},
          rotation=360,
          thickness=0.5),
        Text(
          extent={{-40,20},{40,-20}},
          lineColor={238,46,47},
          lineThickness=0.5,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,0,0},
          textString="dQ = 0")}),Documentation(info="<html>
<p>Model of important cooling circuit components that needs to be used with the engine model to realise its heat transfer.</p>
<p>Therefore a heat port is implemented as well as temperature sensors to capture the in- and outlet temperatures of the coolant medium for engine calculations.</p>
<p>Depending on the unit configuration this model can be placed inside the cooling circuit before or after the fluid ports of the exhaust heat exchanger.</p>
<h4>Assumptions:</h4>
<p>The pressure level within the cooling circuit is assumed to be constant at about 3 bar.</p>
</html>"));
end Submodel_Cooling;