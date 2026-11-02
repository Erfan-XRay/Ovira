# OpenAPI document

Every endpoint on these pages is described in one OpenAPI 3.1 document. You can import it into an API client, generate a typed client, or feed it to a test tool. This page covers where to download it, how to import it, and how to generate a client.

## Download

The copy that matches these docs:

[openapi.json](/openapi.json)

Save it with curl or your browser:

```bash
curl -fsSL -o openapi.json https://erfan-xray.github.io/Ovira/openapi.json
```

Every panel also serves the exact document for its running version:

```text
https://panel.example.com/<secret-path>/api/openapi.json
```

The `info.version` there is the panel's version, so a client generated from one panel matches that panel. The docs copy describes `0.9.9-beta.6`. Use the running panel’s document when integrating with an installed panel.

## Before you import

The document's paths start with `/api/`, and its server is the panel root. Set the tool's base URL to the panel address and secret path, **without** the trailing `api/`:

```text
https://panel.example.com/<secret-path>/
```

Then `/api/clients` resolves correctly. Do not paste the **API base URL** from Settings here: that value already ends in `/api`, and the document's paths add it again. If your tool asks for a variable, use the panel address and secret path for `baseUrl` or `host`.

Set the bearer token as an environment variable or a collection variable, not in the file. The document declares `bearerAuth` as `Authorization: Bearer ovk_...`. A token request needs no CSRF header.

Subscription paths (`/{subPath}/{token}/...`) use the public origin without the secret panel path. Set that server separately when calling subscription methods from an imported or generated client.

## Postman

1. Open **Import**.
2. Choose **File** and select `openapi.json`.
3. Import as a collection.
4. Open the collection's **Variables** and set the base URL to the panel address and secret path.
5. Add an **Authorization** header with `Bearer ovk_...` at the collection level, or use Postman's **Bearer Token** auth.

Postman reads the path parameters, query parameters and JSON bodies from the document.

## Insomnia

1. Open **Import**.
2. Choose **From File** and select `openapi.json`.
3. Pick the collection or the request folder to import.
4. Set the environment's base URL to the panel address and secret path.
5. Add a bearer token to the environment and use it in the **Auth** tab.

## Bruno

1. Open the collection menu and choose **Import Collection**.
2. Choose **OpenAPI V3** and select `openapi.json`.
3. Set the environment variable for the base URL.
4. Add a **Bearer** auth at the collection level with `{{token}}`.

Bruno keeps the imported requests as files, so they can go into a repository without the secret.

## Generate a client

[OpenAPI Generator](https://openapi-generator.tech/docs/installation/) can generate a client in the language you choose. Its npm wrapper needs Java. OpenAPI 3.1 support depends on the generator and version; review and test the generated client before using it. With Node installed:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g python \
  -o ./ovira-client
```

Replace `python` with another generator, for example `typescript-fetch`, `go` or `csharp`. The generator's own options set the package name, library and date types:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-fetch \
  -o ./ovira-client \
  --additional-properties=npmName=ovira-client,supportsES6=true
```

Then read the generated `README.md` for the exact class and method names. Most generators create a `Configuration` or `ApiClient` object with a base path and a bearer token; set the base path to the panel address and secret path as above.

Generated clients follow the document. They do not know your reseller's allowed groups or inbounds, so a create call still needs a group or inbound id that the account may use.

## Keep it in step

Download the panel's own `api/openapi.json` after an update if you depend on a newer field or endpoint. The docs copy changes with the documentation release, not with every panel build.

## Related pages

- [API overview](/api/): base address, sign-in and errors.
- [API tokens](/api/tokens): creating the token the document expects.
- [Endpoint reference](/api/reference/): the same endpoints with prose and examples.

Import workflows: [Postman](https://learning.postman.com/docs/integrations/available-integrations/working-with-openAPI/), [Insomnia](https://developer.konghq.com/insomnia/import-export/), [Bruno](https://blog.usebruno.com/keep-your-api-collections-in-sync-with-openapi-sync). Menu labels can vary by version.
