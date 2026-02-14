.PHONY: help run-uat run-prod run-prod-release build-appbundle-prod

# Display help information
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  run-uat               Run app in UAT environment"
	@echo "  run-prod              Run app in Production environment (debug mode)"
	@echo "  run-prod-release      Run app in Production environment (release mode)"
	@echo "  build-appbundle-prod  Build Android App Bundle for Production"
	@echo "  help                  Display this help information"


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
