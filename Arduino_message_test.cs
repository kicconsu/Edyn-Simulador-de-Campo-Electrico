using Godot;
using System;
using System.IO.Ports;

public partial class Arduino_message_test : Node2D
{
	SerialPort serialPort;
	public static Arduino_message_test Instance { get; private set; }
	public String SerialMessage { get; set;} ="39";
	
	public override void _Ready()
	{
		Instance =this;
		
		serialPort = new SerialPort();
		serialPort.PortName = "COM9"; // ajustar al puerto necesario
		serialPort.BaudRate = 9600;

		try
		{
			serialPort.Open();
			GD.Print("Puerto serial abierto exitosamente.");
		}
		catch (Exception e)
		{
			GD.PrintErr("Error al abrir el puerto serial: " + e.Message);
			
		}
	}

	public override void _Process(double delta)
	{
		if (serialPort == null || !serialPort.IsOpen) return;

		try
		{
			SerialMessage = serialPort.ReadLine();
			GD.Print("Distancia recibida: " + SerialMessage);
			
		}
		catch (TimeoutException)
		{
			GD.Print("Tiempo de espera agotado al leer el puerto serial.");
		}
	}

	public override void _ExitTree()
	{
		if (serialPort != null && serialPort.IsOpen)
		{
			serialPort.Close();
			GD.Print("Puerto serial cerrado.");
		}
	}
}
