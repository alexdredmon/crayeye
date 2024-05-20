# crayeye

Open-source multimodal LLM visual analysis utility.  Build & share AI vision prompts augmented with native device sensor data.


Learn more via [https://crayeye.com](https://crayeye.com/)

## Setup

Install [Flutter](https://docs.flutter.dev/get-started/install).

If you want to set a default API key for your dev environment, you can set the environment variable `DEFAULT_OPENAI_API_KEY`.

To start the local dev environment, from within the `./flutter` directory run `./flutter_run.sh` (to pass along a default OpenAI API key) or execute `flutter run`.

## Build

To build the app for iOS/Android, you can use the `open_xcode.sh` or `open_android_studio.sh` scripts to open the corresponding SDK.  Within XCode, you can generate a build via Product->Archive, within Android SDK you can create a build via Build -> Generate Signed Bundle/APK.

## Contributing

To contribute to this project, open a pull request or an issue.

## Install

Install via the:
 - [Apple App Store](https://apps.apple.com/us/app/crayeye/id6480090992)
 - [Google Play Store](https://play.google.com/store/apps/details?id=com.crayeye.app)

## How it's made
CrayEye is the product of A.I. driven development.  [Read more](https://www.alexandriaredmon.com/blog/the-app-that-ai-made) about how it was created.

## Local models
You can configure custom engines using the OpenAPI spec which allows you to use any models you like.  Here's an example of how to run and connect to the open-source Llava model:

#### Step 1: Install Ollama
Download and install Ollama from [https://github.com/ollama/ollama](https://github.com/ollama/ollama).

Install a multimodal model such as Llava via:
```bash
ollama run llava
```

#### Step 2: Expose Ollama
Using a tool such as [ngrok](https://ngrok.com/), expose the locally running model (or skip this step if you're on the same network as your locally running model and want to access it via network hostname).

Using ngrok, ensure to pass along host headers - e.g. to run on port 11434 run:
```bash
ngrok http 11434 --host-header="localhost:11434"
```

#### Step 3: Add custom engine
In CrayEye, add an OpenAPI spec corresponding to your running instance.  For example if your host is `http://hostname` you could add the following definition to connect to the `llava` model running on it via Ollama:
```
{
  'url': 'http://hostname/api/generate',
  'method': 'POST',
  'headers': {
    'Content-Type': 'application/json'
  },
  'body': {
      "model": "llava:latest",
      "prompt": "{prompt}",
      "images": [
        "{imageBase64}"
      ],
      "stream": true
    },
    "responseShape": [
      "response"
    ]
  ,
  'responseShape': ['response']
}
```

`responseShape` indicates which key(s) the response is expected in - for ollama, that's just "response" directly off the object returned by the API.

## Backronym
*"Cognitive Recognition Analysis Yielding Eye"*

## License

Copyright 2024 Alexandria Redmon

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
