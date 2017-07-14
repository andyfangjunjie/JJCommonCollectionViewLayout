Pod::Spec.new do |s|
s.name = 'JJCommonCollectionViewLayout'
s.version = '0.0.1'
s.platform = :ios, '7.0'
s.summary = '一个很好用的collectioinViewLayout，只需遵守几个代理，即可实现想要的布局，你值得拥有'
s.homepage = 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout'
s.license = 'MIT'
s.author = { 'andyfangjunjie' => 'andyfangjunjie@163.com' }
s.source = {:git => 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout.git', :tag => s.version}
s.source_files = 'JJCommonCollectionViewLayout/**/*.{h,m}'
s.requires_arc = true
s.framework  = 'UIKit'
end
