.PHONY: run-fake help run-uat run-prod run-prod-release build-appbundle-prod test-ui test-ui-native

# Display help information
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  run-uat               Run app in UAT environment"
	@echo "  run-fake              Run app with Fake Auth (using UAT Firebase)"
	@echo "  run-prod              Run app in Production environment (debug mode)"
	@echo "  run-prod-release      Run app in Production environment (release mode)"
	@echo "  build-appbundle-prod  Build Android App Bundle for Production"
	@echo "  test-ui               Run UI integration tests in Dart"
	@echo "  test-ui-native        Run UI integration tests as native Android tests (Espresso)"
	@echo "  help                  Display this help information"


# Run app with Fake Auth (using UAT Firebase)
run-fake:
	flutter run --flavor uat -t lib/main_fake.dart

# Run app in UAT environment
run-uat:
	flutter run --flavor uat --dart-define=ENV=uat

# Run app in Production environment (debug mode)
run-prod:
	flutter run --flavor prod --dart-define=ENV=prod

# Run app in Production environment (release mode)
run-prod-release:
	flutter run --flavor prod --release --dart-define=ENV=prod

# Build Android App Bundle for Production
build-appbundle-prod:
	flutter build appbundle --flavor prod --release --dart-define=ENV=prod

# Run UI integration tests (Dart)
test-ui:
	flutter test integration_test/ui_integration_test.dart --flavor uat

# Run UI integration tests (Native/Espresso)
test-ui-native:
	cd android && gradlew app:connectedDebugAndroidTest -Ptarget=integration_test/ui_integration_test.dart
