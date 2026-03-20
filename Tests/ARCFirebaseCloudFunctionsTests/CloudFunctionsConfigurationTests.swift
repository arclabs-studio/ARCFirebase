import Testing
@testable import ARCFirebaseCloudFunctions

@Suite("CloudFunctionsConfiguration Tests")
struct CloudFunctionsConfigurationTests {
    @Test("Default configuration uses us-central1 region") func defaultConfiguration_usesUsCentral1() {
        let config = CloudFunctionsConfiguration.default

        #expect(config.region == "us-central1")
    }

    @Test("Default configuration has 60-second timeout") func defaultConfiguration_has60SecondTimeout() {
        let config = CloudFunctionsConfiguration.default

        #expect(config.defaultTimeout == 60)
    }

    @Test("Europe configuration uses europe-west1 region") func europeConfiguration_usesEuropeWest1() {
        let config = CloudFunctionsConfiguration.europe

        #expect(config.region == "europe-west1")
    }

    @Test("Europe configuration has 60-second timeout") func europeConfiguration_has60SecondTimeout() {
        let config = CloudFunctionsConfiguration.europe

        #expect(config.defaultTimeout == 60)
    }

    @Test("Custom configuration stores region and timeout") func customConfiguration_storesProperties() {
        let config = CloudFunctionsConfiguration(region: "asia-northeast1", defaultTimeout: 30)

        #expect(config.region == "asia-northeast1")
        #expect(config.defaultTimeout == 30)
    }

    @Test("Default init uses us-central1 and 60 seconds") func defaultInit_usesDefaults() {
        let config = CloudFunctionsConfiguration()

        #expect(config.region == "us-central1")
        #expect(config.defaultTimeout == 60)
    }
}
