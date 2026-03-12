/// flutter_rust_bridge:ignore
pub mod chart_provider;
/// flutter_rust_bridge:ignore
pub mod content_importer;
/// flutter_rust_bridge:ignore
pub mod content_resolver;
/// flutter_rust_bridge:ignore
pub mod lyrics_provider;
/// flutter_rust_bridge:ignore
pub mod search_suggestions;

/// flutter_rust_bridge:ignore
pub use chart_provider::ChartProviderPluginAdapter;
/// flutter_rust_bridge:ignore
pub use content_importer::ContentImporterPluginAdapter;
/// flutter_rust_bridge:ignore
pub use content_resolver::ContentResolverPluginAdapter;
/// flutter_rust_bridge:ignore
pub use lyrics_provider::LyricsProviderPluginAdapter;
/// flutter_rust_bridge:ignore
pub use search_suggestions::SearchSuggestionPluginAdapter;

/// flutter_rust_bridge:ignore
pub fn register_builtin_adapters(registrar: &mut crate::api::plugin::registrar::PluginRegistrar) {
	fn register_adapter<T: crate::api::plugin::types::PluginAdapter>(
		registrar: &mut crate::api::plugin::registrar::PluginRegistrar,
	) {
		let plugin_type = T::plugin_type();
		if let Err(err) = registrar.register_plugin(plugin_type, |name, path, engine| {
			Box::pin(T::create(name, path, engine))
		}) {
			tracing::error!(
				plugin_type = ?plugin_type,
				error = %err,
				"Failed to register plugin adapter"
			);
		}
	}

	register_adapter::<ContentResolverPluginAdapter>(registrar);
	register_adapter::<ChartProviderPluginAdapter>(registrar);
	register_adapter::<LyricsProviderPluginAdapter>(registrar);
	register_adapter::<SearchSuggestionPluginAdapter>(registrar);
	register_adapter::<ContentImporterPluginAdapter>(registrar);
}
