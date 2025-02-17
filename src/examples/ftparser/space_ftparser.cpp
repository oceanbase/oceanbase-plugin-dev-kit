/*
 * Copyright (c) 2025 OceanBase.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <new>

#include "oceanbase/ob_plugin_ftparser.h"

/**
 * @defgroup ExampleFtParser Fulltext Parser Plugin Example
 * @brief This is an example for fulltext parser plugin
 * @{
 */

namespace oceanbase {
namespace example {

class ObSpaceFTParser final
{
public:
  ObSpaceFTParser() = default;
  virtual ~ObSpaceFTParser();

  int init(ObPluginDatum param);
  void reset();
  int get_next_token(
      const char *&word,
      int64_t &word_len,
      int64_t &char_len,
      int64_t &word_freq);

private:
  ObPluginDatum  cs_   = 0;
  const char *   start_     = nullptr;
  const char *   next_      = nullptr;
  const char *   end_       = nullptr;
  bool           is_inited_ = false;
};

#define	_MY_U	01	  
#define	_MY_L	02	  
#define	_MY_NMR	04	
#define	_MY_SPC	010	
#define	_MY_PNT	020	
#define	_MY_CTR	040	
#define	_MY_B	0100	
#define	_MY_X	0200	

#define true_word_char(ctype, character) ((ctype) & (_MY_U | _MY_L | _MY_NMR) || (character) == '_')

ObSpaceFTParser::~ObSpaceFTParser()
{
  reset();
}

void ObSpaceFTParser::reset()
{
  cs_ = 0;
  start_ = nullptr;
  next_ = nullptr;
  end_ = nullptr;
  is_inited_ = false;
}

int ObSpaceFTParser::init(ObPluginFTParserParamPtr param)
{
  int ret = OBP_SUCCESS;
  const char *fulltext = obp_ftparser_fulltext(param);
  int64_t ft_length = obp_ftparser_fulltext_length(param);
  ObPluginCharsetInfoPtr cs = obp_ftparser_charset_info(param);

  if (is_inited_) {
    ret = OBP_INIT_TWICE;
    OBP_LOG_WARN("init twice. ret=%d, param=%p, this=%p", ret, param, this);
  } else if (0 == param
      || 0 == cs
      || nullptr == fulltext
      || 0 >= ft_length) {
    ret = OBP_INVALID_ARGUMENT;
    OBP_LOG_WARN("invalid arguments, ret=%d, param=%p", ret, param);
  } else {
    cs_ = cs;
    start_ = fulltext;
    next_ = start_;
    end_ = start_ + ft_length;
    is_inited_ = true;
  }
  if (ret != OBP_SUCCESS && !is_inited_) {
    reset();
  }
  OBP_LOG_INFO("ftparser init done. ret=%d", ret);
  return ret;
}

int ObSpaceFTParser::get_next_token(
    const char *&word,
    int64_t &word_len,
    int64_t &char_len,
    int64_t &word_freq)
{
  int ret = OBP_SUCCESS;
  int mbl = 0;
  word = nullptr;
  word_len = 0;
  char_len = 0;
  word_freq = 0;
  if (!is_inited_) {
    ret = OBP_PLUGIN_ERROR;
    OBP_LOG_WARN("space ft parser isn't initialized. ret=%d, is_inited=%d", ret, is_inited_);
  } else {
    const char *start = start_;
    const char *next = next_;
    const char *end = end_;
    const ObPluginCharsetInfoPtr cs = cs_;
    do {
      while (next < end) {
        int ctype;
        mbl = obp_charset_ctype(cs, &ctype, (unsigned char *)next, (unsigned char *)end);
        if (true_word_char(ctype, *next)) {
          break;
        }
        next += mbl > 0 ? mbl : (mbl < 0 ? -mbl : 1);
      }
      if (next >= end) {
        ret = OBP_ITER_END;
      } else {
        int64_t c_nums = 0;
        start = next;
        while (next < end) {
          int ctype;
          mbl = obp_charset_ctype(cs, &ctype, (unsigned char *)next, (unsigned char *)end);
          if (!true_word_char(ctype, *next)) {
            break;
          }
          ++c_nums;
          next += mbl > 0 ? mbl : (mbl < 0 ? -mbl : 1);
        }
        if (0 < c_nums) {
          word = start;
          word_len = next - start;
          char_len = c_nums;
          word_freq = 1;
          start = next;
          break;
        } else {
          start = next;
        }
      }
    } while (ret == OBP_SUCCESS && next < end);
    if (OBP_ITER_END == ret || OBP_SUCCESS == ret) {
      start_ = start;
      next_ = next;
      end_ = end;
    }
    OBP_LOG_TRACE("next word. start=%p, next=%p, end=%p", start_, next_, end_);
  }
  return ret;
}

} // namespace example
} // namespace oceanbase

using namespace oceanbase::example;

int ftparser_scan_begin(ObPluginFTParserParamPtr param)
{
  int ret = OBP_SUCCESS;
  ObSpaceFTParser *parser = new (std::nothrow) ObSpaceFTParser;
  ret = parser->init(param);
  if (OBP_SUCCESS != ret) {
    delete parser;
    return ret;
  }
  obp_ftparser_set_user_data(param, (parser));
  return OBP_SUCCESS;
}

int ftparser_scan_end(ObPluginFTParserParamPtr param)
{
  ObSpaceFTParser *parser = (ObSpaceFTParser *)(obp_ftparser_user_data(param));
  delete parser;
  obp_ftparser_set_user_data(param, 0);
  return OBP_SUCCESS;
}

int ftparser_next_token(ObPluginFTParserParamPtr param,
                        char **word,
                        int64_t *word_len,
                        int64_t *char_cnt,
                        int64_t *word_freq)
{
  int ret = OBP_SUCCESS;
  if (word == nullptr || word_len == nullptr || char_cnt == nullptr || word_freq == nullptr) {
    ret = OBP_INVALID_ARGUMENT;
  } else {
    ObSpaceFTParser *parser = (ObSpaceFTParser *)(obp_ftparser_user_data(param));
    ret = parser->get_next_token((const char *&)(*word), *word_len, *char_cnt, *word_freq);
  }
  return ret;
}

int ftparser_get_add_word_flag(uint64_t *flag)
{
  int ret = OBP_SUCCESS;
  if (flag == nullptr) {
    ret = OBP_INVALID_ARGUMENT;
  } else {
    *flag = OBP_FTPARSER_AWF_MIN_MAX_WORD
            | OBP_FTPARSER_AWF_STOPWORD
            | OBP_FTPARSER_AWF_CASEDOWN
            | OBP_FTPARSER_AWF_GROUPBY_WORD;
  }
  return ret;
}

/**
 * plugin init function
 * @param plugin The plugin param
 * @details This function will be called when OceanBase load the library.
 * We register the plugin(s) in this function and we can initialize other
 * variables here.
 */
int plugin_init(ObPluginParamPtr plugin)
{
  int ret = OBP_SUCCESS;
  /// A ftparser plugin descriptor
  ObPluginFTParser parser = {
    .init              = NULL,
    .deinit            = NULL,
    .scan_begin        = ftparser_scan_begin,
    .scan_end          = ftparser_scan_end,
    .next_token        = ftparser_next_token,
    .get_add_word_flag = ftparser_get_add_word_flag
  };

  /// register the ftparser plugin
  ret = OBP_REGISTER_FTPARSER(plugin,
                              "example_ftparser",
                              parser,
                              "This is an example ftparser.");
  return ret;
}

OBP_DECLARE_PLUGIN(example_ftparser)
{
  OBP_AUTHOR_OCEANBASE,       // 作者
  OBP_MAKE_VERSION(1, 0, 0),  // 当前插件库的版本
  OBP_LICENSE_MULAN_PSL_V2,   // 该插件的license
  plugin_init, // init        // 插件的初始化函数，在plugin_init中注册各个插件功能
  nullptr, // deinit          // 插件的析构函数
} OBP_DECLARE_PLUGIN_END;

/** @} */
