import Openai;


function printSlow(text:String, delay:Float)
{
	final stdo = Sys.stdout();
	for (ch in 0...text.length)
	{
		final char = text.charAt(ch);
		stdo.writeString(char);
		stdo.flush();
		if (char != " ")
		{
			Sys.sleep(delay);
		}
	}
	stdo.writeString("\n");
}


function input(prompt:String)
{
	Sys.print(prompt);
	return(Sys.stdin().readLine());
	
}

/**
	Usage:
	  gptcli [optional params] [userinput: string]
	
	Options:
**/
class Main extends mcli.CommandLine
{
	/**
		Show this message.
	**/
	public function help()
		{
			Sys.println(this.showUsage());
			Sys.exit(0);
		}
	
	/**
		open chat
	**/
	public var start:Bool;

	/**
		instantly print all of the response
	**/
	public var instant:Bool;

	/**
		prints entire json for debugging
	**/
	public var verbose:Bool;

	/**
		select a different model
	**/
	public var model:String = "text-davinci-003";

	/**
		choose the max length of the response
	**/
	public var length:Int = 2048;

	/**
		the elvel of randomness in model's response
	**/
	public var temperature:Float = 0.5;

	/**
		choose an environment variable from which the api key is taken
	**/
	public var apiKeyVar:String = "OPENAI_API_KEY";

	public function runDefault(?text:String)
	{
		//final joinedtext = text.join(" ");
		var completer = new Completion(openaiToken(apiKeyVar));

		if (start)
		{
			Sys.println("Type quit to stop");
			while (true)
			{
				final data = input("\nYou: ");

				if (data != "quit")
				{
					final resp = completer.create(model, data, temperature, length);
					final output = StringTools.trim(resp.choices[0].text);

					if (verbose)
					{
						Sys.println("\n" + haxe.Json.stringify(resp) + "\n");
					}

					Sys.print("\nAI: ");
					if (instant)
					{
						Sys.println(output);
					}
					else
					{
						printSlow(output, 0.01);
					}
					
				}
				else
				{
					Sys.exit(0);
				}
			}
		}
		else 
		{
			final resp = completer.create(model, text, temperature, length);
			final output = StringTools.trim(resp.choices[0].text);
			
			if (verbose)
			{
				Sys.println("\n" + haxe.Json.stringify(resp) + "\n");
			}

			if (instant)
			{
				Sys.println(output);
			}
			else
			{
				printSlow(output, 0.01);
			}
		}
		Sys.exit(0);
	}

	public static function main()
	{
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}

}