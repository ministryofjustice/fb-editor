require("govuk-frontend/govuk/all").initAll()
// require.context('govuk-frontend/govuk/assets/images', true)

// Use direct filesystem paths to avoid package exports directory resolution issues
 require.context('../../../node_modules/govuk-frontend/govuk/assets/images', true, /\.(png|svg|ico|jpg|jpeg|gif)$/)
 require.context('../../../node_modules/govuk-frontend/govuk/assets/fonts', true, /\.(woff2?|ttf|eot)$/)
import "./stylesheets/govuk.scss"
