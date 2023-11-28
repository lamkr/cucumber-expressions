import 'transformer.dart';

final class TransformerAdaptor<In, Out>
    implements CaptureGroupTransformer<In, Out>
{
  final Transformer<In, Out> transformer;

  TransformerAdaptor(this.transformer);

  @override
  Out transform(List<In> args) {
    return transformer.transform(args[0]);
  }
}
