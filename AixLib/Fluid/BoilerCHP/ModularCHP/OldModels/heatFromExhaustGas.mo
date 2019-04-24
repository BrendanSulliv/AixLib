within AixLib.Fluid.BoilerCHP.ModularCHP.OldModels;
model heatFromExhaustGas
  OldModels.HeatConvPipeInsideDynamic heatConvExhaustPipeInside(d_i=d_iExh,
      A_sur=3) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-54,0})));
  Modelica.Fluid.Vessels.ClosedVolume volExhaust(
    redeclare final package Medium = Medium1,
    final m_flow_nominal=m1_flow_nominal,
    final p_start=p1_start,
    final T_start=T1_start,
    use_HeatTransfer=true,
    redeclare model HeatTransfer =
        Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.IdealHeatTransfer,
    use_portsData=false,
    final m_flow_small=m1_flow_small,
    nPorts=2,
    V=0.002)                           "Fluid volume"
    annotation (Placement(transformation(extent={{-40,60},{-20,40}})));
  FixedResistances.HydraulicDiameter
                                pressureDropExhaust(
    redeclare final package Medium = Medium1,
    final show_T=false,
    final allowFlowReversal=allowFlowReversal1,
    final m_flow_nominal=m1_flow_nominal,
    dh=d_iExh,
    rho_default = 1.18,
    mu_default=1.82*10^(-5),
    length=l_Exh)                  "Pressure drop"
    annotation (Placement(transformation(extent={{0,54},{20,74}})));
  replaceable package Medium1 =
      DataBase.CHP.ModularCHPEngineMedia.CHPFlueGasLambdaOnePlus
    constrainedby Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
  parameter Boolean allowFlowReversal1 = true
    annotation (Dialog(tab="Advanced", group="Port properties"));
  parameter Modelica.SIunits.Temperature T1_start=TAmb
    "Initial or guess value of output (= state)"
    annotation (Dialog(tab="Advanced", group="Initialization"));
  parameter Modelica.SIunits.MassFlowRate m1_flow_nominal=0.023
  "Nominal value for mass flow rates in ports"
    annotation (Dialog(tab="Advanced", group="Port properties"));
  parameter Modelica.SIunits.MassFlowRate m1_flow_small=0.0001
  "Regularization range at zero mass flow rate"
    annotation (Dialog(tab="Advanced", group="Port properties"));
  parameter Modelica.Media.Interfaces.Types.AbsolutePressure p1_start=pAmb
    "Start value of pressure"
    annotation (Dialog(tab="Advanced", group="Initialization"));
 /* parameter Modelica.SIunits.Area A_surExhHea=3
 "Surface for exhaust heat transfer" annotation (Dialog(tab="Calibration parameters"));  */
  parameter Modelica.SIunits.Length d_iExh=0.06
    "Inner diameter of exhaust pipe"
    annotation (Dialog(group="Input"));
  parameter Modelica.SIunits.Temperature TAmb=298.15
    "Fixed ambient temperature for heat transfer"
    annotation (Dialog(group="Ambient Properties"));
  parameter Modelica.Media.Interfaces.Types.AbsolutePressure pAmb=101325
    "Start value of pressure"
    annotation (Dialog(group="Ambient Properties"));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b port_b annotation (
      Placement(transformation(rotation=0, extent={{-10,-100},{10,-80}}),
        iconTransformation(extent={{-10,-100},{10,-80}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b1(redeclare final package Medium =
        Medium1) annotation (Placement(transformation(rotation=0, extent={{90,34},
            {110,54}}), iconTransformation(extent={{90,34},{110,54}})));
  Modelica.Fluid.Interfaces.FluidPort_a                 ports(redeclare each
      package Medium = Medium1) annotation (Placement(transformation(rotation=0,
          extent={{-110,34},{-90,54}}), iconTransformation(extent={{-110,34},{-90,
            54}})));
  Modelica.Blocks.Sources.RealExpression massFlowExhaustGas(y=m_flow)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}})));
  Modelica.Blocks.Interfaces.RealOutput m_flow=0.023
    "Mass flow rate of exhaust gas" annotation(Dialog(group="Input"));
  parameter Modelica.SIunits.Length l_Exh=1
    "Length of the exhaust pipe inside the exhaust heat exchanger"
    annotation (Dialog(group="Input"));

equation
  connect(heatConvExhaustPipeInside.port_a, volExhaust.heatPort)
    annotation (Line(points={{-54,10},{-54,50},{-40,50}}, color={191,0,0}));
  connect(port_b, heatConvExhaustPipeInside.port_b)
    annotation (Line(points={{0,-90},{0,-50},{-54,-50},{-54,-10}},
                                                   color={191,0,0}));
  connect(pressureDropExhaust.port_b, port_b1)
    annotation (Line(points={{20,64},{50,64},{50,44},{100,44}},
                                               color={0,127,255}));
  connect(ports, volExhaust.ports[1])
    annotation (Line(points={{-100,44},{-64,44},{-64,64},{-32,64},{-32,60}},
                                                           color={0,127,255}));
  connect(pressureDropExhaust.port_a, volExhaust.ports[2])
    annotation (Line(points={{0,64},{-28,64},{-28,60}},   color={0,127,255}));
  connect(massFlowExhaustGas.y, heatConvExhaustPipeInside.m_flow) annotation (
      Line(points={{-11,0},{-28,0},{-28,0.4},{-43.2,0.4}}, color={0,0,127}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{-100,82},{100,0}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={192,192,192}),
        Rectangle(
          extent={{-100,64},{100,18}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255}),
        Line(
          points={{0,0},{0,-40},{0,-80}},
          color={238,46,47},
          thickness=1),
        Line(
          points={{0,0},{-12,-14},{12,-14},{0,0}},
          color={238,46,47},
          thickness=1),
        Line(
          points={{0,7},{-12,-7},{12,-7},{0,7}},
          color={238,46,47},
          thickness=1,
          origin={0,-73},
          rotation=180),
        Text(
          extent={{6,-26},{68,-54}},
          lineColor={0,0,0},
          lineThickness=1,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={238,46,47},
          textString="Q_flow",
          textStyle={TextStyle.Bold}),
        Polygon(
          points={{0,0},{-12,-14},{12,-14},{0,0}},
          lineColor={238,46,47},
          lineThickness=1,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={238,46,47}),
        Polygon(
          points={{0,7},{-12,-7},{12,-7},{0,7}},
          lineColor={238,46,47},
          lineThickness=1,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={238,46,47},
          origin={0,-73},
          rotation=180)}));
end heatFromExhaustGas;