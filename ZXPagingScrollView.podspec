Pod::Spec.new do |s|
s.name         = 'ZXPagingScrollView'
s.version      = '1.0.6'
s.summary      = '【基于MJRefresh】，两行代码完成tableView与collectionView分页加载全部效果'
s.homepage     = 'https://github.com/SmileZXLee/ZXPagingScrollView'
s.license      = 'MIT'
s.authors      = {'李兆祥' => '393727164@qq.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/SmileZXLee/ZXPagingScrollView.git', :tag => s.version}
s.source_files = 'ZXPagingScrollViewDemo/ZXPagingScrollViewDemo/ZXPagingScrollView/**/*'
s.requires_arc = true
s.dependency 'MJRefresh'
end