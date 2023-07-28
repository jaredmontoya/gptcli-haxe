package;


/**
        Gets OpenAI token from environment variable
**/
function openaiToken(envar: String): String
{
    if (Sys.getEnv(envar) == null) 
    {
        Sys.println('Environment variable $envar is not set, you can get one here: https://beta.openai.com/account/api-keys');
        Sys.println("add this:");
        Sys.println('  export $envar=your api key');
        Sys.println("to your .bashrc or .zshrc");
        Sys.println("or if you are on windows, edit environment variables in the settings");
        
        Sys.exit(1);

        return("");
    }
    else
    {
        return(Sys.getEnv(envar));
    }
}

/**
    a data structure that represents sub json returned from OpenAI API
**/
typedef Choices =
{
    var text:String;
    var index:Int;
    var logprobs:Null<String>;
    var finish_reason:String;
}

/**
    A data structure that represents json returned from OpenAI API
**/
typedef OpenaiApiResponse =
{
    var id:String;
    var object:String;
    var created:Int;
    var model:String;
    var choices:Array<Choices>;
}


class Completion
{
    public function new(apiKey:String)
    {
        this.apiKey = apiKey;
    }

    private final apiUrl = "https://api.openai.com/v1/completions";

    public var apiKey:String;

    /**
        Creates a new completion for the provided prompt and parameters
    **/
    public function create(engine:String, prompt:String, temperature:Float, max_tokens: Int):OpenaiApiResponse {
        var request = new haxe.Http(apiUrl);

        request.addHeader("Content-Type", "application/json");
        request.addHeader("Authorization", 'Bearer $apiKey');

        final body =
        {
            "model": engine,
            "prompt": prompt,
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        request.setPostData(haxe.Json.stringify(body));
        
        var response = "";
        request.onData = function (data)
        {
            response = data;
        }

        request.onError = function(error)
        {
            Sys.println(error);
        }

        request.onStatus = function(status)
        {
            if (status == 400)
            {
                Sys.println("Some of the parameters that you provided are invalid");
            }
            else if (status == 401)
            {
                Sys.println("The API key that you provided is invalid");
            }
            else if (status == 404)
            {
                Sys.println("The model that you selected does not exist");
            }
        }
        request.request(true);
        return(haxe.Json.parse(response));
    }
}